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
import KakaoSDKCommon

/// :nodoc: 카카오 로그인 인증서버로 API 요청을 담당하는 클래스입니다.
///
/// 주로 토큰 요청 기능이 제공되지만 `AuthController`의 로그인 기능을 사용하면 내부적으로 토큰 요청이 처리되고, API 사용 중 토큰이 만료되었을 때 갱신 요청도 자동으로 처리되므로 **이 클래스를 직접 사용하지 않아도 무방**합니다.
final public class AuthApi {
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = AuthApi()
    
    // MARK: Methods    
    
    /// :nodoc: 인증코드 요청입니다. TODO: 제거?
    public func authorizeRequest(parameters:[String:Any]) -> URLRequest? {
        guard let finalUrl = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters) else { return nil }
        return URLRequest(url: finalUrl)
    }
    
    /// :nodoc: 동적 동의 요청시 인증값으로 사용되는 임시토큰 발급 요청입니다. SDK 내부 전용입니다.
    public func agt(completion:@escaping (String?, Error?) -> Void) {
        Api.shared.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authAgt),
                                parameters: ["client_id":try! KakaoSDKCommon.shared.appKey(), "access_token":auth.tokenManager.getToken()?.accessToken].filterNil(),
                                sessionType:.Auth,
                                apiType: .KApi) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                                            completion(json["agt"] as? String, nil)
                                            return
                                        }
                                    }
                                    
                                    completion(nil, SdkError())
                                }
    }
    
    /// 사용자 인증코드를 이용하여 신규 토큰 발급을 요청합니다.
    public func token(grantType: String = "authorization_code",
                      clientId: String = try! KakaoSDKCommon.shared.appKey(),
                      redirectUri: String = try! KakaoSDKCommon.shared.redirectUri(),
                      code: String,
                      completion:@escaping (OAuthToken?, Error?) -> Void) {
        Api.shared.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":grantType,
                                             "client_id":clientId,
                                             "redirect_uri":redirectUri,
                                             "code":code,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let oauthToken = try? SdkJSONDecoder.custom.decode(OAuthToken.self, from: data) {
                                            auth.tokenManager.setToken(oauthToken)
                                            completion(oauthToken, nil)
                                            return
                                        }
                                    }
                                    completion(nil, SdkError())
                                }
    }
    
    /// 기존 토큰을 갱신합니다.
    public func refreshAccessToken(clientId: String = try! KakaoSDKCommon.shared.appKey(),
                                   refreshToken: String? = nil,
                                   completion:@escaping (OAuthToken?, Error?) -> Void) {
        Api.shared.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"refresh_token",
                                             "client_id":clientId,
                                             "refresh_token":refreshToken ?? auth.tokenManager.getToken()?.refreshToken,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let newToken = try? SdkJSONDecoder.custom.decode(Token.self, from: data) {
                                        
                                            //oauthtoken 객체가 없으면 에러가 나야함.
                                            guard let oldOAuthToken = auth.tokenManager.getToken()
                                            else {
                                                completion(nil, SdkError(reason: .TokenNotFound))
                                                return
                                            }
                                            
                                            var newRefreshToken: String {
                                                if let refreshToken = newToken.refreshToken {
                                                    return refreshToken
                                                }
                                                else {
                                                    return oldOAuthToken.refreshToken
                                                }
                                            }
                                            
                                            var newRefreshTokenExpiresIn : TimeInterval {
                                                if let refreshTokenExpiresIn = newToken.refreshTokenExpiresIn {
                                                    return refreshTokenExpiresIn
                                                }
                                                else {
                                                    return oldOAuthToken.refreshTokenExpiresIn
                                                }
                                            }
                                            
                                            let oauthToken = OAuthToken(accessToken: newToken.accessToken,
                                                                        expiresIn: newToken.expiresIn,
                                                                        tokenType: newToken.tokenType,
                                                                        refreshToken: newRefreshToken,
                                                                        refreshTokenExpiresIn: newRefreshTokenExpiresIn,
                                                                        scope: newToken.scope,
                                                                        scopes: newToken.scopes)
                                            
                                            auth.tokenManager.setToken(oauthToken)
                                            completion(oauthToken, nil)
                                            return
                                        }
                                    }
                                    
                                    completion(nil, SdkError())
                                }
    }   
}
