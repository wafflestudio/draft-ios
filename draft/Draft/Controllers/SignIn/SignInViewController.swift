//
//  SigninViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/10.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import Alamofire
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
    
    
    // MARK: for authLogin
    var userparam: UserParam? = nil
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
    func goToOAuthSignUpView(param: UserParam) {
        
        guard let oAuthSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "OAuthSignUp") as? OAuthSignUpViewController
            else {
                return
        }
        
        oAuthSignUpViewController.setParam(param)
        self.navigationController?.pushViewController(oAuthSignUpViewController, animated: true)
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
