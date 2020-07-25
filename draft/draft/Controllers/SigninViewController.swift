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
import FBSDKLoginKit
import Alamofire

class SigninViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
}
