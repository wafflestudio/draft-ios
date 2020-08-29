//
//  User.swift
//  draft
//
//  Created by 한상현 on 2020/07/21.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

struct User {
    
    static var shared = User()
    
    private init() {}
    
    private(set) var jwtToken: String?
    private(set) var userName: String?
    private(set) var userEmail: String?
    
    mutating func setJwtToken(_ jwtToken: String) {
        self.jwtToken = jwtToken
    }
    
    mutating func setUserName(_ userName: String) {
        self.userName = userName
    }
    
    mutating func setUserEmail(_ userEmail: String) {
        self.userEmail = userEmail
    }
}
