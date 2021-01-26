//
//  APIRequests+user.swift
//  Draft
//
//  Created by JSKeum on 2020/10/30.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation
import Alamofire

enum UserRequestType {
    case signIn
    case signUp
}

struct UserParam : Encodable {
    let grantType : String
    let authProvider : String?
    let accessToken : String?
    let username: String?
}

struct UserResponseData: Decodable {
    let createdAt: String
    let updatedAt: String
    let username: String
    let email: String
    let password: Int?
    let roles: String?
    let rooms: String?
    let devices: String?
    let region: String?
    let profileImage: String?
    let id: Int
}

enum UserRequestError {
    case responseError
    case noUserInDB
}

extension APIRequests {
    func requestUser(param: UserParam?, requestType: UserRequestType, completion: @escaping (_: UserResponseData?, _ : UserRequestError?) -> Void) {
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
                            return
                        }
                        
                        User.shared.setJwtToken(jwt)
                        completion(nil, nil)
                        
                    case let .failure(error):
                        if (res.response?.statusCode == 404) {
                            completion(nil, .noUserInDB)
                        }
                        debugPrint(error.errorDescription)
                        completion(nil, .responseError)
                    }
            }
        case .signUp:
            AF.request(APIUrl.signupUrl,
                       method: .post,
                       parameters: param,
                       encoder: JSONParameterEncoder.default)
                .validate().responseJSON() { res in
                    
                    switch res.result {
                    case .success:
                        if let data = res.data, let decodedData = try? JSONDecoder().decode(UserResponseData.self, from: data) {
                            
                            completion(decodedData, nil)
                        } else {
                            completion(nil, .responseError)
                        }
                        
                    case let .failure(error):
                        print("SIGN UP ERROR: \(error.underlyingError.debugDescription)")
                        completion(nil, .responseError)
                        
                    }
            }
        }
    }
}

func userQueryBuild(grantType: String, authProvider: String?, accessToken: String?, username: String?) -> UserParam {
    return UserParam(grantType: grantType, authProvider: authProvider, accessToken: accessToken, username: username)
}

