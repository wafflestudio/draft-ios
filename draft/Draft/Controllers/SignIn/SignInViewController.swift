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
//import FBSDKLoginKit
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
        //        let header : HTTPHeader = [
        //        ]
        
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

// MARK: Signin To Server
extension SignInViewController {
    func tokenSignIn(token : String, provider : String, email: String) {
        let url = APIUrl.signinUrl 
        
        struct Param : Encodable {
            let grantType : String
            let authProvider : String
            let accessToken : String
        }
        
        let param = Param(grantType: GrantType.OAUTH, authProvider: provider, accessToken: token)
        
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoder: JSONParameterEncoder.default).validate().responseJSON() {
                    response in
                    
                    if (response.response?.statusCode == 204) {
                        
                        if let jwtToken = response.response?.headers.dictionary["Authentication"] {
                            
                            User.shared.setJwtToken(jwtToken)
                            User.shared.setUserEmail(email)
                            self.goToDetailView()
                        }
                    }
                    
                    if (response.response?.statusCode == 404) {
                        // token이 valid 하나 user data가 없으므로 signup view로 이동
                        self.goToOAuthSignUpView(token: token, provider: provider)
                        
                    }
                    
                    if (response.response?.statusCode == 401) {
                        // token이 vaild 하지 않음
                    }
                    //            NotificationCenter.default.addObserver(self, selector: #selector(SigninViewController.sendDeviceToken(_:)), name: NSNotification.Name(rawValue: "DeviceToken"), object: nil)
                    // DeviceToken 전달 부분 보완 필요
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
        let idToken = user.authentication.idToken
        let email = user.profile.email
        
        if let token = idToken {
            tokenSignIn(token: token, provider: OAuthProvider.GOOGLE, email: email!)
        }
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
                            self.tokenSignIn(token: token, provider: "KAKAO", email: "")
                        }
                        else {
                            guard let email = user?.kakaoAccount?.email else {
                                print("No Kakao Account Email from User")
                                self.tokenSignIn(token: token, provider: "KAKAO", email: "")
                                return
                            }
                            
                            self.tokenSignIn(token: token, provider: "KAKAO", email: email)
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

//    func FacebookLogin(){
//        let loginButton = FBLoginButton()
//        loginButton.center = view.center
//        loginButton.permissions = ["email"]
//        view.addSubview(loginButton)
//        // Do any additional setup after loading the view.
//
//        if let token = AccessToken.current, !token.isExpired {
//            // User is logged in, do work such as go to next view controller.
//            tokenProcessing(Token: token.tokenString, Provider: "FACEBOOK")
//        }
//    }



//    @IBAction func KakaologinButtonClicked() {
////        if(AuthController.isTalkAuthAvailable()){
////            let token : OAuthToken
////            let error : Error
////            AuthController.shared.authorizeWithTalk(channelPublicIds: <#T##[String]?#>, serviceTerms: <#T##[String]?#>, autoLogin: <#T##Bool?#>, completion: <#T##(OAuthToken?, Error?) -> Void#>)
////            print(token)
////        }
////
//        if (AuthController.isTalkAuthAvailable()) {
//            AuthController.shared.authorizeWithTalk(completion:{ (token,error) in
//                self.tokenProcessing(Token: token!.accessToken,Provider: "KAKAO")
//            })
//        }
//    }

