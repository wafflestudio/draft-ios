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

import Foundation

/// 카카오 SDK 공통의 환경변수 설정을 위한 클래스입니다.
///
/// 싱글톤으로 제공되는 인스턴스를 사용해야 하며 다음과 같이 초기화할 수 있습니다.
///
///     // AppDelegate.swift
///     func application(_ application: UIApplication,
///                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///
///         KakaoSDKCommon.shared.initSDK(appKey: "<#Your App Key#>")
///
///         return true
///     }
/// - important: SDK 초기화가 수행되지 않으면 SDK 내 모든 기능을 사용할 수 없습니다. 반드시 가장 먼저 실행되어야 합니다.
public final class KakaoSDKCommon {
    
    // MARK: Fields
    
    /// 카카오 SDK의 싱글톤 객체입니다. SDK를 사용할 때 반드시 이 객체가 가장 먼저 초기화되어야 합니다.
    public static let shared = KakaoSDKCommon()
    
    private var _appKey : String? = nil
    private var _customRedirectUri : String? = nil
    private var _loggingEnable : Bool = false
    
    private var _hosts : Hosts? = nil
    
    public init() {
        _appKey = nil
        _customRedirectUri = nil
    }
    
    
    // MARK: Initializers
    
    /// SDK 초기화를 수행합니다.
    /// - parameters:
    ///   - appKey: [개발자사이트](https://developers.kakao.com)에서 발급 받은 NATIVE_APP_KEY.
    ///   - customRedirectUri: 로그인 시 인증코드를 발급 받을 URI. 내 앱의 커스텀 스킴에 로그인 요청임을 구분할 수 있는 host 및 path를 덧붙여 사용한다. ex) myappscheme://oauth
    ///   - loggingEnable: SDK에서 발생하는 로그 사용 여부.
    public func initSDK(appKey: String, customRedirectUri: String? = nil, loggingEnable: Bool = false, hosts: Hosts? = nil) {
        _appKey = appKey
        _customRedirectUri = customRedirectUri
        _loggingEnable = loggingEnable
        _hosts = hosts
        
        SdkLog.shared.clearLog()        
    }
    
    /// 현재 SDK의 버전을 조회합니다.
    public func sdkVersion() -> String {
        //앱스토어 서밋버전스펙 에러때문에 plist 버전은 2.0.0으로, 실제버전은 베타버전을 하드코딩한다. (베타버전 동안 == 정식버전 전까지)
        return "2.0.0-beta.5"
//        let bundle = Bundle(for: type(of: self))
//        if let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
//            SdkLog.d("sdk_version : \(version)")
//            return version
//        }
//        else {
//            SdkLog.e("not_defined_version")
//            return "not_defined_version"
//        }
    }
    
    /// 초기화 시 지정한 loggingEnable
    /// - seealso: `SdkLog`
    public func isLoggingEnable() -> Bool {
        return _loggingEnable
    }
    
    public func hosts() -> Hosts {
        return _hosts != nil ? _hosts! : Hosts.shared
    }    
}

extension KakaoSDKCommon {
    /// 설정된 앱키를 가져옵니다.
    /// - throws: `SdkError.ClientFailureReason.MustInitAppKey`: SDK가 초기화되지 않았습니다. 앱키를 가져오기 전에 initSDK를 이용하여 먼저 싱글톤 인스턴스를 초기화해야 합니다.
    public func appKey() throws -> String {
        guard _appKey != nil else {
            throw SdkError(reason: .MustInitAppKey)
        }
        return _appKey!
    }
    
    /// :nodoc: TODO: 여기 있어야 하는가? AuthController 파라미터로 리팩토링 해보자
    public func redirectUri() throws -> String {
        guard _appKey != nil else {
            throw SdkError(reason: .MustInitAppKey)
        }
        return _customRedirectUri ?? "kakao\(_appKey!)://oauth"
    }
}
