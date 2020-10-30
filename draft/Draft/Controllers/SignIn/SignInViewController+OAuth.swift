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

// MARK: Apple Login
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
            
            APIRequests.shared.requestUser(param: param, requestType: .signIn) { _ , error  in
                if let error = error {
                    switch error {
                    case .noUserInDB:
                        #warning("TODO: Go to signup view")
                        print("error")
                        return
                        
                    default:
                        #warning("TODO: 에러 처리")
                        print("Error")
                        return
                    }
                }
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
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: Google Signin
extension SignInViewController: GIDSignInDelegate {
    func googleSignInSetup() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            }
            else {
                print("\(error.localizedDescription)")
            }
            return
        }
        guard let token = user.authentication.idToken, let identifier = user.authentication.clientID, let email = user.profile.email else {
            print("Cannot get google access authorization")
            return
        }
        
        let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: OAuthProvider.GOOGLE, accessToken: token, username: nil, email: email)
        
        APIRequests.shared.requestUser(param: param, requestType: .signIn) { _ , error  in
            if let error = error {
                switch error {
                case .noUserInDB:
                    #warning("TODO: Go to signup view")
                    print("error")
                    return
                    
                default:
                    #warning("TODO: 에러 처리")
                    print("Error")
                    return
                }
            }
            self.goToDetailView()
        }
        
        KeychainAccess.shared.saveOAuthInKeychain(identifier: identifier, accessToken: Data(token.utf8), type: .googleOAuth)
        
    }
}

extension SignInViewController {
    @IBAction func KakaologinButtonClicked() {
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            
            AuthApi.shared.loginWithKakaoAccount(authType: .Reauthenticate) {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    guard let token = oauthToken?.accessToken else {
                        print("No Kakao Access Token from oauthToken")
                        return
                    }

                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: OAuthProvider.KAKAO, accessToken: token, username: "test name", email: user?.kakaoAccount?.email)
                            
                            APIRequests.shared.requestUser(param: param, requestType: .signIn) { _, error in
                                if let error = error {
                                    switch error {
                                    case .noUserInDB:
                                        #warning("TODO: Go to signup view")
                                        print("error")
                                        return
                                        
                                    default:
                                        #warning("TODO: 에러 처리")
                                        print("Error")
                                        return
                                    }
                                }
                                self.goToDetailView()
                            }
                        }
                    }
                }
            }
        }
    }
}
