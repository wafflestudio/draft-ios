//
//  APIRequests.swift
//  Draft
//
//  Created by JSKeum on 2020/10/25.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation
import Alamofire

enum RequestType {
    case signIn
    case signUp
    case getRoomsByRegion
    case singleRoom
}

enum ResponseDataType {
    case getRoom(GetRoomByRegionResponseData)
    case signIn(SignInResponseData)
}

struct GetRoomByRegionResponseData: Decodable {
    let id: Int
    let name: String
    let depth1: String?
    let depth2: String?
    let depth3: String?
    let rooms: [Room]
}

struct SignInResponseData: Decodable {
    let jwt: String
}

struct Param : Encodable {
    let grantType : String
    let authProvider : String?
    let accessToken : String?
    let username: String?
    let email: String?
}



class APIRequests {
    static var shared = APIRequests()
    
    var oauthTokenHeader: HTTPHeaders {
        return ["Authentication": User.shared.jwtToken ?? ""]
    }
    
    func request(param: Param?, requestType: RequestType, completion: @escaping (_ : Data?) -> Void) {
        switch requestType {
        case .signIn:
            AF.request(APIUrl.signinUrl,
                       method: .post,
                       parameters: param,
                       encoder: JSONParameterEncoder.default)
                .validate().responseJSON() { res in
                     switch res.result {
                           case .success:
                                guard let jwt = res.response?.headers["Authentication"] else {
                                    #warning("TODO: 에러 처리")
                                    print("Error: Cannot get jwt from server")
                                    return
                                }
                                
                                User.shared.setJwtToken(jwt)
                                completion(nil)
                        
                           case let .failure(error):
                               #warning("TODO: 로그인 실패 시 에러 처리")
                               print(error)
                           }
            }
        case .signUp:
            AF.request(APIUrl.signupUrl,
                       method: .post,
                       parameters: param,
                       encoder: JSONParameterEncoder.default)
                .validate().responseJSON() { response in
                    #warning("TODO: 에러 처리")
                    completion(nil)
            }
        case .getRoomsByRegion:
            AF.request(APIUrl.getRoomUrl,
                       method: .get,
                       parameters: param,
                       encoder: JSONParameterEncoder.default,
                       headers: oauthTokenHeader)
                .validate().responseJSON() { res in
                    
                    switch res.result {
                    case .success:
                    if let data = res.data {
                            completion(data)
                    }
                        
                    case let .failure(error):
                        #warning("TODO: 에러 처리")
                        print(error)
                    }
            }
        case .singleRoom:
            AF.request(APIUrl.signupUrl,
                       method: .post,
                       parameters: param,
                       encoder: JSONParameterEncoder.default)
                .validate().responseJSON() { response in
                    #warning("TODO: 에러 처리")
                    completion(nil)
            }
        }
    }
}

func userQueryBuild(grantType: String, authProvider: String?, accessToken: String?, username: String?, email: String?) -> Param {
    
    return Param(grantType: grantType, authProvider: authProvider, accessToken: accessToken, username: username, email: email)
}
