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
import RxKakaoSDKAuth
import FBSDKLoginKit

class SigninViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBLoginButton()
        loginButton.center = view.center
        loginButton.permissions = ["email"]
        view.addSubview(loginButton)
        // Do any additional setup after loading the view.
        
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            
        }
    }
    
    @IBAction func KakaologinButtonClicked() {
//        if(AuthController.isTalkAuthAvailable()){
//            let token : OAuthToken
//            let error : Error
//            AuthController.shared.authorizeWithTalk(channelPublicIds: <#T##[String]?#>, serviceTerms: <#T##[String]?#>, autoLogin: <#T##Bool?#>, completion: <#T##(OAuthToken?, Error?) -> Void#>)
//            print(token)
//        }
//
        if (AuthController.isTalkAuthAvailable()) {
            AuthController.shared.authorizeWithTalk(completion:{ (token,error) in
                SdkLog.d("token id ::::: \(token?.accessToken ?? "default val")")
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
