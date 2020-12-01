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
            
            self.oAuthSignIn(oAuthProvider: OAuthProvider.APPLE, userName: nil, email: email, token: String(decoding: token, as: UTF8.self))
            
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
        
        self.oAuthSignIn(oAuthProvider: OAuthProvider.GOOGLE, userName: nil, email: email, token: token)
        
        KeychainAccess.shared.saveOAuthInKeychain(identifier: identifier, accessToken: Data(token.utf8), type: .googleOAuth)
        
    }
}

extension SignInViewController {
    @IBAction func KakaologinButtonClicked() {
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            
            AuthApi.shared.loginWithKakaoAccount(authType: .Reauthenticate) {[weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    guard let strongSelf = self, let token = oauthToken?.accessToken else {
                        print("No Kakao Access Token from oauthToken")
                        return
                    }

                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            strongSelf.oAuthSignIn(oAuthProvider: OAuthProvider.KAKAO, userName: "test name", email: user?.kakaoAccount?.email, token: token)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Sign In Logic
extension SignInViewController {
    private func oAuthSignIn(oAuthProvider: String, userName: String?, email: String?, token: String) {
        let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: oAuthProvider, accessToken: token, username: userName, email: email)
        
        APIRequests.shared.requestUser(param: param, requestType: .signIn) { [weak self] _, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                switch error {
                case .noUserInDB:
                    print("SignIn Failed : \(error)")
                    
                    strongSelf.oAuthSignUp(oAuthProvider: oAuthProvider, userName: userName, email: email, token: token)
                    
                    return
                    
                default:
                    #warning("TODO: 에러 처리")
                    print("Error")
                    return
                }
            }
            
            strongSelf.goToDetailView()
        }
    }
}

// MARK: Sign Up Logic
extension SignInViewController {
    private func oAuthSignUp(oAuthProvider: String, userName: String?, email: String?, token: String) {
        let param = userQueryBuild(grantType: GrantType.OAUTH, authProvider: oAuthProvider, accessToken: token, username: userName, email: email)
        
        APIRequests.shared.requestUser(param: param, requestType: .signUp) { [weak self] _, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                print("SignUp Error : \(error)")
                
                let alert = UIAlertController(title: "회원가입 실패", message: "다시 시도해주세요", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(confirm)
                strongSelf.present(alert, animated: true, completion: nil)
                
                return
            }
            
            strongSelf.oAuthSignIn(oAuthProvider: oAuthProvider, userName: userName, email: email, token: token)
        }
    }
}

