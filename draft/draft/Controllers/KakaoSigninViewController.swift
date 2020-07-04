//
//  KakaoSigninViewController.swift
//  draft
//
//  Created by 한상현 on 2020/07/04.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import RxKakaoSDKCommon
import KakaoSDKAuth
// import RxKakaoSDKAuth

class KakaoSigninViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonClicked() {
            func loginButtonClicked() {
              if (AuthController.isTalkAuthAvailable()) {
                
                AuthController.shared.authorizeWithTalk { (OAuthToken, Error) in
                     print(OAuthToken)
                }
                
//                AuthController.shared.authorizeWithTalk()
//                                            .subscribe(onNext:{ (oauthToken) in
//                                              print(oauthToken)
//                                            })
//                                            .disposed(by: self.disposeBag)
//                }
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
