//
//  OAuthSignUPViewController.swift
//  draft
//
//  Created by JSKeum on 2020/08/28.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import Alamofire

class OAuthSignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private(set) var accessToken: String?
    private(set) var provider: String?
    
    func setAccessToken(_ accessToken: String) {
        self.accessToken = accessToken
    }
    
    func setProvider(_ provider: String) {
        self.provider = provider
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func oAuthSignUp(_ sender: UIButton) {
        if let username = usernameTextField.text {
            oAuthSignUpRequest(username: username, token: self.accessToken!, provider: self.provider!)
        }
    }
}

// MARK: - UITextField Delegate
extension OAuthSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= 10
    }
}

// MARK: - OAuth SignUp Request
extension OAuthSignUpViewController {
    func oAuthSignUpRequest(username: String, token: String, provider: String) {
        struct Param : Encodable {
            let grantType : String
            let authProvider : String
            let accessToken : String
            let username: String
        }
        
        let param = Param(grantType: GrantType.OAUTH, authProvider: provider, accessToken: token, username: username)
        
        AF.request(APIUrl.signupUrl,
                   method: .post,
                   parameters: param,
                   encoder: JSONParameterEncoder.default)
            .validate().responseJSON() {
                    response in
                    
                    if (response.response?.statusCode == 201) {
                        
                        if let jwtToken = response.response?.headers.dictionary["Authentication"] {
                            
                            User.shared.setJwtToken(jwtToken)
                            print("회원가입 성공! : \(response.response!)")
                            self.goToDetailView()
                        }
                    }
                    
                    if (response.response?.statusCode == 400) {
                        print("error: statusCode == 400 when signUp request")
                        print(response.response!)
                    }
        }
    }
}

// MARK: - Go To Detail View
extension OAuthSignUpViewController {
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
