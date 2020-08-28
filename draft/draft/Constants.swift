//
//  Constants.swift
//  draft
//
//  Created by JSKeum on 2020/08/28.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

struct OAuthProvider {
    
    static let GOOGLE = "GOOGLE"
    static let KAKAO = "KAKAO"
    static let FACEBOOK = "FACEBOOK"
}

struct APIUrl {
    
    static let signinUrl = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signin/"
    static let signupUrl = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signup/"
    
    static let deviceRegisterUrl =  "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/device/"
}

struct GrantType {
    
    static let PASSWORD = "PASSWORD"
    static let OAUTH = "OAUTH"
}
