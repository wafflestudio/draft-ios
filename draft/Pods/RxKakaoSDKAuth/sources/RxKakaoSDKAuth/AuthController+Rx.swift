//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit
import RxSwift
import RxCocoa
import SafariServices
import AuthenticationServices

import KakaoSDKCommon
import KakaoSDKAuth

import RxKakaoSDKCommon

let authController = AuthController.shared

/// 카카오 로그인의 주요 기능을 제공하는 클래스입니다.
///
/// 이 클래스를 이용하여 **카카오톡 간편로그인** 또는 웹 쿠키를 이용한 로그인을 수행할 수 있습니다.
///
/// 카카오톡 간편로그인 예제입니다.
///
///     // 로그인 버튼 클릭
///     if (AuthController.isTalkAuthAvailable()) {
///         AuthController.shared.authorizeWithTalk()
///             .subscribe(onNext: { (token) in
///                 print(token)
///             }, onError: { (error) in
///                 print(error)
///             })
///             .disposed(by: self.disposeBag)
///     }
///
///     // AppDelegate
///     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
///         if AuthController.handleOpenUrl(url: url, options: options) {
///             return true
///         }
///         ...
///     }
///
/// 웹 로그인 예제입니다.
///
///     AuthController.shared.authorizeWithAuthenticationSession()
///         .subscribe(onNext: { (token) in
///             print(token.accessToken)
///         }, onError: { (error) in
///             print(error)
///         })
///         .disposed(by: self.disposeBag)

extension AuthController: ReactiveCompatible {}

extension Reactive where Base: AuthController {

//extension AuthController {
        
    // MARK: Login with KakaoTalk
    
    /// 카카오톡 간편로그인을 실행합니다.
    /// - note: isTalkAuthAvailable() 메소드로 실행 가능한 상태인지 확인이 필요합니다. 카카오톡을 실행할 수 없을 경우 authorizeWithAuthenticationSession() 메소드로 웹 로그인을 시도할 수 있습니다.
    public func authorizeWithTalk(channelPublicIds: [String]? = nil,
                                  serviceTerms: [String]? = nil,
                                  autoLogin: Bool? = nil) -> Observable<OAuthToken> {
        return Observable<String>.create { observer in
            authController.authorizeWithTalkCompletionHandler = { (callbackUrl) in
                let parseResult = callbackUrl.oauthResult()
                if let code = parseResult.code {
                    observer.onNext(code)
                } else {
                    let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                    SdkLog.e("Failed to parse redirect URI.")
                    observer.onError(error)
                }
            }
            
            var parameters = [String:Any]()
            parameters["client_id"] = try! KakaoSDKCommon.shared.appKey()
            parameters["redirect_uri"] = try! KakaoSDKCommon.shared.redirectUri()
            parameters["response_type"] = Constants.responseType
        
            parameters["headers"] = ["KA": Constants.kaHeader].toJsonString()
            
            var extraParameters = [String: Any]()
            extraParameters["channel_public_id"] = channelPublicIds?.joined(separator: ",")
            extraParameters["service_terms"] = serviceTerms?.joined(separator: ",")
            extraParameters["auto_login"] = autoLogin
            if extraParameters.count > 0 {
                parameters["params"] = extraParameters.toJsonString()
            }

            guard let url = SdkUtils.makeUrlWithParameters(Urls.compose(.TalkAuth, path:Paths.authTalk), parameters: parameters) else {
                SdkLog.e("Bad Parameter.")
                observer.onError(SdkError(reason: .BadParameter))
                return Disposables.create()
            }
            
            UIApplication.shared.open(url, options: [:]) { (result) in
                if (result) {
                    SdkLog.d("카카오톡 실행: \(url.absoluteString)")
                }
                else {
                    SdkLog.e("카카오톡 실행 취소")
                    observer.onError(SdkError(reason: .Cancelled, message: "The KakaoTalk authentication has been canceled by user."))
                    return
                }
            }
            
            return Disposables.create()
        }
        .flatMap { code in
            AuthApi.shared.rx.token(code: code)
        }
    }
    
    /// **카카오톡 간편로그인** 등 외부로부터 리다이렉트 된 코드요청 결과를 처리합니다.
    /// AppDelegate의 openURL 메소드 내에 다음과 같이 구현해야 합니다.
    ///
    /// ```
    /// func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    ///     if AuthController.rx.handleOpenUrl(url: url, options: options) {
    ///         return true
    ///     }dk
    ///
    ///     // 서비스의 나머지 URL 핸들링 처리
    /// }
    ///
    public static func handleOpenUrl(url:URL,  options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthController.isValidRedirectUri(url)) {
            if let authorizeWithTalkCompletionHandler = authController.authorizeWithTalkCompletionHandler {
                authorizeWithTalkCompletionHandler(url)
            }
        }
        return false
    }
    
    // MARK: Login with Web Cookie
    
    /// iOS 11 이상에서 제공되는 (SF/ASWeb)AuthenticationSession 을 이용하여 로그인 페이지를 띄우고 쿠키 기반 로그인을 수행합니다. 이미 사파리에에서 로그인하여 카카오계정의 쿠키가 구워져 있다면 이를 활용하여 ID/PW 입력 없이 간편하게 로그인할 수 있습니다.
    public func authorizeWithAuthenticationSession() -> Observable<OAuthToken> {
        return self.authorizeWithAuthenticationSession(agtToken: nil,
                                                       scopes: nil,
                                                       channelPublicIds: nil,
                                                       serviceTerms:nil)
    }
    
    /// :nodoc: 카카오싱크 전용입니다. 자세한 내용은 카카오싱크 전용 개발가이드를 참고하시기 바랍니다.
    public func authorizeWithAuthenticationSession(channelPublicIds: [String]? = nil,
                                                   serviceTerms: [String]? = nil,
                                                   autoLogin: Bool? = nil) -> Observable<OAuthToken> {
        return self.authorizeWithAuthenticationSession(agtToken: nil,
                                                       scopes: nil,
                                                       channelPublicIds: channelPublicIds,
                                                       serviceTerms:serviceTerms,
                                                       autoLogin: autoLogin)
    }
    
    
    // MARK: New Agreement
    
    /// 사용자로부터 카카오가 보유중인 사용자 정보 제공에 대한 동의를 받습니다.
    ///
    /// 카카오로부터 사용자의 정보를 제공 받거나 카카오서비스 접근권한이 필요한 경우, 사용자로부터 해당 정보 제공에 대한 동의를 받지 않았다면 이 메소드를 사용하여 **동적 동의**를 받아야 합니다.
    /// 필요한 동의항목과 매칭되는 scope id를 배열에 담아 파라미터로 전달해야 합니다. 동의항목과 scope id를 확인하시려면 *개발자사이트 사용자관리 > 동의항목 설정*을 참고하실 수 있습니다.
    ///
    /// ## 사용자 동의 획득 시나리오
    /// 간편로그인 또는 웹 로그인을 수행하면 최초 로그인 시 개발자사이트에 설정된 동의항목 설정에 따라 사용자의 동의를 받습니다. 동의항목을 설정해도 상황에 따라 동의를 받지 못할 수 있습니다. 대표적인 케이스는 아래와 같습니다.
    /// - **선택** 으로 설정된 동의항목이 최초 로그인시 선택받지 못한 경우
    /// - **필수** 로 설정하였지만 해당 정보가 로그인 시점에 존재하지 않아 카카오에서 동의항목을 보여주지 못한 경우
    /// - 사용자가 해당 동의항목이 설정되기 이전에 로그인한 경우
    ///
    /// 이외에도 다양한 여건에 따라 동의받지 못한 항목이 발생할 수 있습니다.
    ///
    /// ## 동적 동의 주의사항
    /// **선택** 으로 설정된 동의항목에 대한 **동적 동의**는, 반드시 **사용자가 동의를 거부하더라도 서비스 이용이 지장이 없는** 시나리오에서 요청해야 합니다.
    /// 선택 동의를 거부했을 때 서비스를 이용할 수 없도록 구현된 경우 카카오의 운영 정책에 따라 **API 이용제제** 대상이 될 수 있습니다.
    public func authorizeWithAuthenticationSession(scopes:[String]) -> Observable<OAuthToken> {
        return AuthApi.shared.rx.agt().asObservable().flatMap({ agtToken -> Observable<OAuthToken> in
            return self.authorizeWithAuthenticationSession(agtToken: agtToken, scopes: scopes)
        })
    }
    
    func authorizeWithAuthenticationSession(agtToken: String? = nil,
                                            scopes:[String]? = nil,
                                            channelPublicIds: [String]? = nil,
                                            serviceTerms: [String]? = nil,
                                            autoLogin: Bool? = nil) -> Observable<OAuthToken> {
        return Observable<String>.create { observer in
            let authenticationSessionCompletionHandler : (URL?, Error?) -> Void = {
                (callbackUrl:URL?, error:Error?) in
                
                guard let callbackUrl = callbackUrl else {
                    if #available(iOS 12.0, *), let error = error as? ASWebAuthenticationSessionError {
                        if error.code == ASWebAuthenticationSessionError.canceledLogin {
                            SdkLog.e("The authentication session has been canceled by user.")
                            observer.onError(SdkError(reason: .Cancelled, message: "The authentication session has been canceled by user."))
                        } else {
                            // TODO: iOS 13 presentationContextProvider error handling
                            SdkLog.e("An error occurred on executing authentication session.")
                            observer.onError(SdkError(reason: .Unknown, message: "An error occurred on executing authentication session."))
                        }
                    } else if let error = error as? SFAuthenticationError, error.code == SFAuthenticationError.canceledLogin {
                        SdkLog.e("The authentication session has been canceled by user.")
                        observer.onError(SdkError(reason: .Cancelled, message: "The authentication session has been canceled by user."))
                    } else {
                        SdkLog.e("An unknown authentication session error occurred.")
                        observer.onError(SdkError(reason: .Unknown, message: "An unknown authentication session error occurred."))
                    }
                    return
                }
                
                let parseResult = callbackUrl.oauthResult()
                if let code = parseResult.code {
                    SdkLog.i("code:\n \(String(describing: code))\n\n" )
                    observer.onNext(code)
                } else {
                    let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                    SdkLog.e("Failed to parse redirect URI.")
                    observer.onError(error)
                }
            }
            
            var parameters = [String:Any]()
            parameters["client_id"] = try! KakaoSDKCommon.shared.appKey()
            parameters["redirect_uri"] = try! KakaoSDKCommon.shared.redirectUri()
            parameters["response_type"] = Constants.responseType
            parameters["ka"] = Constants.kaHeader
            
            if let agt = agtToken {
                parameters["agt"] = agt
                
                if let scopes = scopes {
                    parameters["scope"] = scopes.joined(separator:" ")
                }
            }
            
            parameters["channel_public_id"] = channelPublicIds?.joined(separator: ",")
            parameters["service_terms"] = serviceTerms?.joined(separator: ",")
            parameters["auto_login"] = autoLogin
            
            if let url = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters) {
                #if DEBUG
                SdkLog.d("\n===================================================================================================")
                SdkLog.d("request: \n url:\(url)\n parameters: \(parameters) \n")
                #endif
                
                if #available(iOS 12.0, *) {
                    let authenticationSession = ASWebAuthenticationSession.init(url: url,
                                                                                 callbackURLScheme: try! KakaoSDKCommon.shared.redirectUri(),
                                                                                 completionHandler:authenticationSessionCompletionHandler)
                    if #available(iOS 13.0, *) {
                        authenticationSession.presentationContextProvider = authController.presentationContextProvider as? ASWebAuthenticationPresentationContextProviding
                        if agtToken != nil {
                            authenticationSession.prefersEphemeralWebBrowserSession = true
                        }
                    }
                    authenticationSession.start()
                    authController.authenticationSession = authenticationSession
                }
                else {
                    authController.authenticationSession = SFAuthenticationSession.init(url: url,
                                                                              callbackURLScheme: try! KakaoSDKCommon.shared.redirectUri(),
                                                                              completionHandler:authenticationSessionCompletionHandler)
                    (authController.authenticationSession as? SFAuthenticationSession)?.start()
                }
            }
            return Disposables.create()
        }
        .flatMap { code in
            AuthApi.shared.rx.token(code: code)
        }
        
    }
}
