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
    static let APPLE = "APPLE"
}

struct APIUrl {
    #if DEBUG
    static let signinUrl = "http://localhost:8080/api/v1/user/signin/"
    static let signupUrl = "http://localhost:8080/api/v1/user/signup/"
    static let deviceRegisterUrl = "http://localhost:8080/api/v1/user/device/"
    static let getRoomUrl = "http://localhost:8080/api/v1/region/room/"
    #else
    static let signinUrl = "https://draft.wafflestudio.com/api/v1/user/signin/"
    static let signupUrl = "https://draft.wafflestudio.com/api/v1/user/signup/"
    static let deviceRegisterUrl = "https://draft.wafflestudio.com/api/v1/user/device/"
    static let getRoomUrl = "https://draft.wafflestudio.com/api/v1/region/room/"
    #endif
}
    
struct GrantType {
    static let PASSWORD = "PASSWORD"
    static let OAUTH = "OAUTH"
}

struct Draft {
    static let roomCellIdentifier = "ReusableCell"
    static let roomCellNibName = "RoomCell"
}
