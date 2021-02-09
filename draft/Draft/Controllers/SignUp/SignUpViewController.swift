//
//  SignUpViewController.swift
//  Draft
//
//  Created by 한상현 on 2021/01/18.
//  Copyright © 2021 JSKeum. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController, UITextFieldDelegate {
    struct Constant {
        static let profileUploadButtonViewCornerRadius = CGFloat(30)
        static let textFieldContainerViewCornerRadius = CGFloat(30)
        static let signupButtonViewCornerRadius = CGFloat(25)
    }
    
    @IBOutlet weak var profileUploadButton: UIButton!
    @IBOutlet weak var nicknameContainerView: UIView!
    @IBOutlet weak var regionContainerView: UIView!
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var birthyearContainerView: UIView!
    
    @IBOutlet weak var signupButton: UIButton!
    private(set) var param: UserParam? = nil
    
    func setParam(_ param: UserParam) {
        self.param = param
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let backButton = UIBarButtonItem(title: "회원가입", style: UIBarButtonItem.Style.done, target: self, action: "back")
        
        //navigationItem.leftBarButtonItem = backButton

        setupView()
        
        // Do any additional setup after loading the view.
    }

    func setupView() {
        self.navigationController?.navigationBar.tintColor = UIColor(ciColor: .black)
        
        let backItem = UIBarButtonItem()
        backItem.title = "회원가입"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        profileUploadButton.layer.cornerRadius = Constant.profileUploadButtonViewCornerRadius
        nicknameContainerView.layer.cornerRadius = Constant.textFieldContainerViewCornerRadius
        regionContainerView.layer.cornerRadius = Constant.textFieldContainerViewCornerRadius
        regionContainerView.layer.cornerRadius = Constant.textFieldContainerViewCornerRadius
        birthyearContainerView.layer.cornerRadius = Constant.textFieldContainerViewCornerRadius
        signupButton.layer.cornerRadius = Constant.signupButtonViewCornerRadius
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= 10
    }
    
//    @IBAction func oAuthSignUp(_ sender: UIButton) {
//        if let username = usernameTextField.text {
//            oAuthSignUpRequest(username: username)
//        }
//    }
}

// MARK: - OAuth SignUp Request
extension SignUpViewController {
    func oAuthSignUpRequest(username: String) {
        guard let param = self.param else {
            //TODO: param 부재 예외 처리
            return
        }
        
        self.param = userQueryBuild(grantType: param.grantType, authProvider: param.authProvider, accessToken: param.accessToken, username: username)
       
        APIRequests.shared.requestUser(param: self.param, requestType: .signUp) { [weak self] _, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                print("SignUp Error : \(error)")
                
                let alert = UIAlertController(title: "회원가입 실패", message: "다시 시도해주세요", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                
                alert.addAction(confirm)
                strongSelf.present(alert, animated: true, completion: nil)
                
                return
            }
            
            
            guard let signInParam = strongSelf.param else {
                return
            }
            
            APIRequests.shared.requestUser(param: signInParam, requestType: .signIn) { [weak self] _, error in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    switch error {
                    case .noUserInDB:
                        print("SignIn Failed : \(error)")
                        strongSelf.navigationController?.popViewController(animated: true)
                        
                    default:
                        #warning("TODO: 에러 처리")
                        print("Error: \(error)")
                        strongSelf.navigationController?.popViewController(animated: true)
                        return
                    }
                }
                
                strongSelf.goToDetailView()
            }
        }
    }
}

// MARK: - Go To MatchingTable View
extension SignUpViewController {
    func goToDetailView() {
        let storyboard = UIStoryboard(name: "MatchingTable", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MatchingTable") as? UITabBarController else {
            print("에러 : MatchingTable로 갈 수 없습니다")
            return
        }
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
