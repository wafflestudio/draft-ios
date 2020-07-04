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


let api = Api.shared
let auth = Auth.shared

public class Auth {
    let sdkVersionKey = "com.kakao.sdk.version"
    static public let retryTokenRefreshCount = 3
    static public let shared = Auth()
    
    public var tokenManager: TokenManagable
    
    public init(tokenManager : TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
        
        initSession()

        //TODO: module 체크에 사용되는 모듈이름이 비rx 모듈이름이어야 한다.
        //비rx 모듈 만들고 나면 그걸로 수정해야함.
        if tokenManager is KakaoSDKAuth.TokenManager {
            MigrateManager.checkSdkVersionForMigration()
        }
    }
    
    func initSession() {
        addSession(type:.AuthApi)
        addSession(type:.RxAuthApi)
    }
    
    private func addSession(type: SessionType) {
        var session : Session

        switch type {
        case .AuthApi:
            
            let adapterAndRetrier = Interceptor(adapter: AuthRequestAdapter(), retrier: AuthRequestRetrier())
            session = Session(configuration: URLSessionConfiguration.default, interceptor: adapterAndRetrier )
            api.addSession(type: type, session: session)
        case .RxAuthApi:
            session = Session(configuration: URLSessionConfiguration.default, interceptor: AuthRequestAdapter())
            api.addSession(type: type, session: session)
        default:
            break
        }
        
        print(">>>> \(api.sessions)")
    }
    
    /// ## 커스텀 토큰 관리자
    /// TokenManagable 프로토콜을 구현하여 직접 토큰 관리자를 구현할 수 있습니다.
    public func setTokenManager(_ tokenManager: TokenManagable = TokenManager.manager) {
        self.tokenManager = tokenManager
    }
    
    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
                             _ url: String,
                             parameters: [String: Any]? = nil,
                             headers: [String: String]? = nil,
                             apiType: ApiType,
                             completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        
        api.responseData(HTTPMethod, url, parameters: parameters, headers: headers, sessionType: .AuthApi, apiType: apiType, completion: completion)
    }
    
    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
                       _ url: String,
                       images: [UIImage?] = [],
                       headers: [String: String]? = nil,
                       apiType: ApiType,
                       completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        api.upload(HTTPMethod, url, images:images, headers: headers, apiType: apiType, completion: completion)
    }
}
