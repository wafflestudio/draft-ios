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

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
    // [START viewcontroller_vars]
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    // [END viewcontroller_vars]
    
    override func viewDidLoad() {
      super.viewDidLoad()

      googleSignIn()
    }
    
    func googleSignIn(){
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()

        // [START_EXCLUDE]
        NotificationCenter.default.addObserver(self,
            selector: #selector(SigninViewController.receiveToggleAuthUINotification(_:)),
            name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil)

        statusText.text = "Initialized Swift app..."
        toggleAuthUI()
    }
    
    // [START signout_tapped]
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
      // [START_EXCLUDE silent]
      statusText.text = "Signed out."
      toggleAuthUI()
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
    // [END disconnect_tapped]
    // [START toggle_auth]
    func toggleAuthUI() {
      if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
        // Signed in
        signInButton.isHidden = true
        signOutButton.isHidden = false
        disconnectButton.isHidden = false
      } else {
        signInButton.isHidden = false
        signOutButton.isHidden = true
        disconnectButton.isHidden = true
        statusText.text = "Google Sign in\niOS Demo"
      }
    }
    // [END toggle_auth]
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return UIStatusBarStyle.lightContent
    }

    deinit {
      NotificationCenter.default.removeObserver(self,
          name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
          object: nil)
    }

    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            self.toggleAuthUI()
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }

                self.statusText.text = userInfo["statusText"]!
                
                guard let token = userInfo["token"] else { return }
                
                print("Token : \(token)")
                let flag = tokenSignIn(Token: token, Provider: "GOOGLE")
                
                if flag == false{
                    tokenSignUp(Token: token, Provider: "GOOGLE", Username: userInfo["username"]!)
                    tokenSignIn(Token: token, Provider: "GOOGLE")
                }
            }
        }
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func PasswordLogin(){
        let url = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signin/"
        struct Param : Encodable {
            let grantType : String
            let email : String
            let password : String
        }
        
        let param = Param(grantType: "PASSWORD",email: emailTextField.text!, password: passwordTextField.text!)
//        let header : HTTPHeader = [
//        ]

        AF.request(url,method:.post,parameters: param,encoder: JSONParameterEncoder.default).validate().responseJSON(){
            response in
            print(response.response?.headers.sorted())
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tokenSignIn(Token : String, Provider : String) -> Bool {
        let url = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signin/"
        
        struct Param : Encodable {
            let grantType : String
            let authProvider : String
            let accessToken : String
        }
        
        let param = Param(grantType: "OAUTH",authProvider: Provider, accessToken: Token)
        
        AF.request(url,method:.post,parameters: param,encoder: JSONParameterEncoder.default).validate().responseJSON(){
            response in
            print("Sign In Header : \(response.response?.headers.dictionary["Authentication"] ?? "No Header")")
            //let userToken = response.response?.headers.dictionary["Authentication"] // 이게 user header
            
//            NotificationCenter.default.addObserver(self, selector: #selector(SigninViewController.sendDeviceToken(_:)), name: NSNotification.Name(rawValue: "DeviceToken"), object: nil)
            // DeviceToken 전달 부분 보완 필요
        }
        
        return false
    }
    
    @objc func sendDeviceToken(_ notification: NSNotification) {
        if notification.name.rawValue == "DeviceToken" {
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }

                guard let deviceToken = userInfo["Devicetoken"] else { return }
                
                print("DeviceToken : \(deviceToken)")
                               
                let url = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/device/"
                
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
    
    func tokenSignUp(Token : String, Provider : String, Username : String) -> Bool {
        let url = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signup/"
        
        struct Param : Encodable {
            let grantType : String
            let authProvider : String
            let accessToken : String
            let username : String
        }
        
        let param = Param(grantType: "OAUTH",authProvider: Provider, accessToken: Token, username: Username)
        
        let result = AF.request(url,method:.post,parameters: param,encoder: JSONParameterEncoder.default).validate().responseJSON(){
            response in
            print("Sign Up: \(response)")
            
//            NotificationCenter.default.addObserver(self, selector: #selector(SigninViewController.sendDeviceToken(_:)), name: NSNotification.Name(rawValue: "DeviceToken"), object: nil)
            // DeviceToken 전달 부분 보완 필요
        }
        
        return result.isFinished
    }
    
    // MARK: - Detail Storyboard로 연결 (지금은 임시로 버튼 연결)
    @IBAction func goToDetailStorybaord(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "RoomDetail", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "RoomDetail") as? UITabBarController else {
            print("에러 : RoomDetailVC로 갈 수 없습니다")
            return
        }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
        
    }
    
}
