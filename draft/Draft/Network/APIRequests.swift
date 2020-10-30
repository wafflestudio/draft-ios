//
//  APIRequests.swift
//  Draft
//
//  Created by JSKeum on 2020/10/25.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation
import Alamofire

class APIRequests {
    static var shared = APIRequests()
    
    internal var oauthTokenHeader: HTTPHeaders {
        return ["Authentication": User.shared.jwtToken ?? ""]
    }
}
