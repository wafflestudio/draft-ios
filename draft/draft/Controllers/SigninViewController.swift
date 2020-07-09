//
//  SigninViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/10.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import KakaoSDKAuth

class SigninViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func KakaologinButtonClicked() {

        if (AuthController.isTalkAuthAvailable()){
            AuthController.shared.authorizeWithTalk() {(OAuthToken,Error) in
                print("\(String(describing: OAuthToken?.accessToken))")
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
