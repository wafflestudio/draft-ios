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
            guard let token = appleIDCredential.identityToken else {
                print("Cannot get apple access token")
                return
            }
            
            KeychainAccess.shared.saveOAuthInKeychain(identifier: userIdentifier, accessToken: token, type: .appleOAuth)
            
            let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: OAuthProvider.APPLE, accessToken: String(decoding: token, as: UTF8.self), username: "test name", email: email)
            
            APIRequests.shared.request(param: param, requestType: .signIn) { _ in
                self.goToDetailView()
            }
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint(error)
        #warning("TODO: 에러 처리")
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
