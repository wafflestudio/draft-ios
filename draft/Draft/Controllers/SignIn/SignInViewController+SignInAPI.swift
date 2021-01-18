//
//  SignInViewController+appleSignIn.swift
//  draft
//
//  Created by JSKeum on 2020/08/29.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import GoogleSignIn



// MARK: Sign In Logic

extension SignInViewController {
    
    func oAuthSignIn(oAuthProvider: String, userName: String?, token: String) {
        self.userparam = userQueryBuild(grantType: GrantType.OAUTH, authProvider: oAuthProvider, accessToken: token, username: userName)
        
        APIRequests.shared.requestUser(param: self.userparam, requestType: .signIn) { [weak self] _, error in
            guard let strongSelf = self else {
                return
            }
            print("PARAM: \(strongSelf.userparam)")
            
            if let error = error {
                switch error {
                case .noUserInDB:
                    print("SignIn Failed : \(error)")
                    
                    
                    guard let param = strongSelf.userparam else {
                        return
                    }
                    
                    strongSelf.goToOAuthSignUpView(param: param)
                    return
                    
                default:
                    #warning("TODO: 에러 처리")
                    print("Error: \(error)")
                    return
                }
            }
            
            strongSelf.goToDetailView()
        }
    }
}

