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
import Alamofire
import KakaoSDKCommon

public class AuthRequestRetrier : RequestInterceptor {
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private var agreementRequestsToRetry: [(RetryResult) -> Void] = []
    
    private var isRefreshing = false
    
    private var errorLock = NSLock()
    
    private func getSdkError(error: Error) -> SdkError? {
        if let aferror = error as? AFError {
            switch aferror {
            case .responseValidationFailed(let reason):
                switch reason {
                case .customValidationFailed(let error):
                    return error as? SdkError
                default:
                    SdkLog.d("don care case")
                }
            default:
                SdkLog.d("don care case")
                
            }
        }
        return nil
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        errorLock.lock() ; defer { errorLock.unlock() }
        
        var logString = "request retrier:"        

        if let sdkError = getSdkError(error: error) {
            if !sdkError.isApiFailed {
                SdkLog.e("\(logString)\n error:\(error)\n not api error -> pass through\n\n")
                completion(.doNotRetry)
                return
            }

            switch(sdkError.getApiError().reason) {
            case .InvalidAccessToken:
                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: auth.tokenManager.getToken()))"
                SdkLog.e("\(logString)\n\n")
                //리프레시 할지말지?
                if shouldRefreshToken(request) {
                    SdkLog.d("---------------------------- enqueue completion\n request: \(request) \n\n")
                    requestsToRetry.append(completion)

                    if !isRefreshing {
                        isRefreshing = true
                        
                        //TODO:딜레이 넣어서 연속된 리퀘스트의 completion 제대로 호출되는지 체크해보자.
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 * 1) {
                            
                        SdkLog.d("<<<<<<<<<<<<<< start token refresh\n request: \(String(describing:request))\n\n")
                        AuthApi.shared.refreshAccessToken { [weak self](token, error) in

                            guard let strongSelf = self else {
                                SdkLog.e("strong self casting error!")
                                //pending 리퀘스트들을 전부 fail.
                                self?.requestsToRetry.forEach {
                                    $0(.doNotRetry)
                                }
                                self?.requestsToRetry.removeAll()
                                self?.isRefreshing = false
                                return
                            }
                            
                            if let error = error {
                                //해당 리퀘스트에 토큰 리프레시 실패로 abort retry.
                                SdkLog.e(">>>>>>>>>>>>>> refreshToken error: \(error). retry aborted.\n request: \(request) \n\n")
                                
                                //pending 리퀘스트들을 전부 fail
                                strongSelf.requestsToRetry.forEach {
                                    $0(.doNotRetry)
                                }                              }
                            else {
                                //해당 리퀘스트에 토큰 리프레시 성공.
                                SdkLog.d(">>>>>>>>>>>>>> refreshToken success\n request: \(request) \n\n")
                                
                                //pending 리퀘스트들을 retry.
                                strongSelf.requestsToRetry.forEach {
                                    $0(.retry)
                                }
                            }
                            
                            strongSelf.requestsToRetry.removeAll() //컴플리션 전부 리셋
                            strongSelf.isRefreshing = false
                        }
                        //}
                    }
                }
                else {
                    //실패로 처리 - 리프레시 하지마라고 해서.
                    SdkLog.e(" should not refresh -> pass through \n")
                    completion(.doNotRetry)
                }
            case .InsufficientScope:
                //동적동의 추가중.
                
                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: auth.tokenManager.getToken()))"
                SdkLog.e("\(logString)\n\n")
                
                if let requiredScopes = sdkError.getApiError().info?.requiredScopes {
                    AuthController.shared.authorizeWithAuthenticationSession(scopes: requiredScopes) { (_, error) in
                        if let _ = error {
                            completion(.doNotRetry)
                        }
                        else {
                            completion(.retry)
                        }
                    }
                }
            default:
                //실패로 처리 - 401이 아님.
                SdkLog.e("\(sdkError)\n not 401,403 error -> pass through \n\n")
                completion(.doNotRetry)
            }
        }
        else {
            //실패로 처리 - 에러정보가 없어서 retry를 할 수 없다.
            SdkLog.e("\(error)\n no error info : should not refresh -> pass through \n\n")
            completion(.doNotRetry)
        }
    }
    
    private func shouldRefreshToken(_ request: Request) -> Bool  {
        guard auth.tokenManager.getToken()?.refreshToken != nil else {
            SdkLog.e(" refresh token not exist. retry aborted.\n\n")
            return false
        }

        return true
    }
}
