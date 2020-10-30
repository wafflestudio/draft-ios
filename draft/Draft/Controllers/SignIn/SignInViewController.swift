//
//  SigninViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/10.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import Alamofire
import AuthenticationServices
import GoogleSignIn

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignInSetup()
    }
    
    @IBAction func googleSignIn(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func appleSignIn(_ sender: UIButton) {
        appleSignIn()
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func PasswordLogin() {
        let url = APIUrl.signinUrl
        
        struct Param : Encodable {
            let grantType : String
            let email : String
            let password : String
        }
        
        let param = Param(grantType: GrantType.PASSWORD ,email: emailTextField.text! , password: passwordTextField.text!)
        
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoder: JSONParameterEncoder.default).validate().responseJSON()
                    {
                        response in
                        print(response.response?.headers.sorted())
        }
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
        
        APIRequests.shared.request(param: param, requestType: .signIn) { _ in
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
                            
                            APIRequests.shared.request(param: param, requestType: .signIn) { _ in
                                self.goToDetailView()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Go To MatchingTable View
extension SignInViewController {
    func goToDetailView() {
        let storyboard = UIStoryboard(name: "MatchingTable", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MatchingTable") as? UITabBarController else {
            print("에러 : MatchingTableVC로 갈 수 없습니다")
            return
        }
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

// MARK: - OAuth SignUp View로 연결
extension SignInViewController {
    func goToOAuthSignUpView(token: String, provider: String) {
        
        guard let oAuthSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "OAuthSignUp") as? OAuthSignUpViewController
            else {
                return
        }
        
        oAuthSignUpViewController.setAccessToken(token)
        oAuthSignUpViewController.setProvider(provider)
        
        navigationController?.pushViewController(oAuthSignUpViewController, animated: true)
    }
}

// MARK: - About Device Token
extension SignInViewController {
    @objc func sendDeviceToken(_ notification: NSNotification) {
        if notification.name.rawValue == "DeviceToken" {
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                
                guard let deviceToken = userInfo["Devicetoken"] else { return }
                
                print("DeviceToken : \(deviceToken)")
                
                let url = APIUrl.deviceRegisterUrl
                
                struct Param : Encodable {
                    let deviceToken : String
                }
                
                let param = Param(deviceToken: deviceToken)
                
                AF.request(url,method:.post,parameters: param,encoder: JSONParameterEncoder.default).responseJSON(){
                    response in
                    print("DeviceToken: \(response)")
                }
                
    
                
            }
            
        }
    }
}
