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
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class SignInViewController: UIViewController {
    
    @IBOutlet weak var kakaoLoginButton: UIView!
    @IBOutlet weak var googleLoginButton: UIView!
    @IBOutlet weak var appleLoginButton: UIView!
    
    override func viewDidLoad() {
        // view
        super.viewDidLoad()
        setupView()
        
        // SignIn Setup
        googleSignInSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setupView(){
        kakaoLoginButton.layer.cornerRadius = 5
        googleLoginButton.layer.cornerRadius = 5
        appleLoginButton.layer.cornerRadius = 5
    }
    
    @IBAction func googleSignIn(recognizer: UITapGestureRecognizer) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func appleSignIn(recognizer: UITapGestureRecognizer) {
        appleSignInStart()
    }
    
    @IBAction func kakaoSignIn(recognizer: UITapGestureRecognizer){
        KakaologinButtonTaped()
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
        
        guard let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "OAuthSignUp") as? SignUpViewController
            else {
                return
        }
        
        signUpViewController.setParam(param)
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

// MARK: Apple Login
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func appleSignInStart() {
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
            
            self.oAuthSignIn(oAuthProvider: OAuthProvider.APPLE, userName: nil, token: String(decoding: token, as: UTF8.self))
            
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
        guard let token = user.authentication.idToken, let identifier = user.authentication.clientID else {
            print("Cannot get google access authorization")
            return
        }
        
        self.oAuthSignIn(oAuthProvider: OAuthProvider.GOOGLE, userName: nil, token: token)
        
        KeychainAccess.shared.saveOAuthInKeychain(identifier: identifier, accessToken: Data(token.utf8), type: .googleOAuth)
        
    }
}

extension SignInViewController {
    func KakaologinButtonTaped() {
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
                            strongSelf.oAuthSignIn(oAuthProvider: OAuthProvider.KAKAO, userName: "test name", token: token)
                        }
                    }
                }
            }
        }
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
