//
//  SigninViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/10.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
//import KakaoSDKAuth
//import KakaoSDKCommon
//import FBSDKLoginKit
import Alamofire
import AuthenticationServices
import GoogleSignIn

class SigninViewController: UIViewController {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignInSetup()
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        // [START_EXCLUDE silent]
        statusText.text = "Signed out."
        // [END_EXCLUDE]
    }
    // [END signout_tapped]
    // [START disconnect_tapped]
    @IBAction func didTapDisconnect(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().disconnect()
        // [START_EXCLUDE silent]
        statusText.text = "Disconnecting."
        // [END_EXCLUDE]
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
extension SigninViewController {
    func tokenSignIn(token : String, provider : String, email: String) -> Bool {
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
                    }
                    
                    if (response.response?.statusCode == 401) {
                        // token이 vaild 하지 않음
                    }
                    //            NotificationCenter.default.addObserver(self, selector: #selector(SigninViewController.sendDeviceToken(_:)), name: NSNotification.Name(rawValue: "DeviceToken"), object: nil)
                    // DeviceToken 전달 부분 보완 필요
        }
        
        return false
    }
}

// MARK: Google Signin
extension SigninViewController: GIDSignInDelegate {
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
        let idToken = user.authentication.idToken // Safe to send to the server
        let email = user.profile.email
        
        if let token = idToken {
            tokenSignIn(token: token, provider: "Google", email: email!)
            print("token : \(token)")
        }
    }
}

// MARK: - Detail Storyboard로 연결 (지금은 임시로 버튼 연결)
extension SigninViewController {
    @IBAction func goToDetailStorybaord(_ sender: UIButton) {
        goToDetailView()
    }
    
    func goToDetailView() {
        let storyboard = UIStoryboard(name: "RoomDetail", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "RoomDetail") as? UITabBarController else {
            print("에러 : RoomDetailVC로 갈 수 없습니다")
            return
        }
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

// MARK: - About Device Token
extension SigninViewController {
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

