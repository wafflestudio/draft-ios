//
//  SignUpViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/22.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {

    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newUsernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickSignUp() {
        struct Param : Encodable {
            let grantType : String
            let email : String
            let password : String
            let username : String
        }
        
        let param = Param(grantType: "PASSWORD",email: newEmailTextField.text!, password: newPasswordTextField.text!, username: newUsernameTextField.text!)

        AF.request(APIUrl.signupUrl,method:.post,parameters: param,encoder: JSONParameterEncoder.default).validate().responseJSON(){
            response in
            
            switch response.result {
            case .success:
                print("Validation Successful")
                print("RES : \(response)")
            case let .failure(error):
                print("ERR : \(error)")
            }
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
