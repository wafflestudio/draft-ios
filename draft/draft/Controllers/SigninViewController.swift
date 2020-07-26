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

                print("Token : \(userInfo["token"] ?? "default")")
                self.statusText.text = userInfo["statusText"]!
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

    func tokenProcessing(Token : String, Provider : String){
        let url = "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signin/"
        let param : Parameters = [
            "grantType" : "OAUTH",
            "authProvider" : Provider,
            "accessToken" : Token
        ]
        
        let alamo = AF.request(url,method:.post,parameters: param)
        
        alamo.responseJSON(){
            response in
            print("JSON : \(response.description)")
        }
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
