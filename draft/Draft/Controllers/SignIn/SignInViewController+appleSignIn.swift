//
//  SignInViewController+appleSignIn.swift
//  draft
//
//  Created by JSKeum on 2020/08/29.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import AuthenticationServices

extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func appleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let identifyToken = appleIDCredential.identityToken
            
            guard let token = identifyToken else {
                print("error: identity token is nil")
                return
            }
            
            KeychainAccess.shared.saveAppleLoginUserIdentifier(identifier: userIdentifier)
            KeychainAccess.shared.saveAppleLoginAccessToken(accessToken: token)
            
            let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: OAuthProvider.APPLE, accessToken: String(data: token, encoding: .utf8), username: "test name", email: email)
            
            APIRequests.shared.request(param: param, requestType: .signIn) { _ in
                self.goToDetailView()
            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
