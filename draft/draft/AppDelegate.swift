//
//  AppDelegate.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit
import CoreData

import GoogleSignIn
//import KakaoSDKCommon
//import KakaoSDKAuth
//import FBSDKCoreKit
//import RxKakaoSDKAuth
//import RxKakaoSDKCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // For device token
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in }
        
        // Google SignIn
        GIDSignIn.sharedInstance().clientID =  "1012204765167-g31h7ml5t3o8nk8isvur6q5s90q7omug.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        //        KakaoSDKCommon.shared.initSDK(appKey: "52f5a0a20ab7c1418e2993f85ca83c29") KaKao
        //
        //        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions ) Facebook
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
        //         if AuthController.handleOpenUrl(url: url, options: options) {
        //             return true
        //         } Kakao
        //
        //        return ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] ) facebook
    }
}

// MARK: - Google Login Delegate
extension AppDelegate: GIDSignInDelegate {
    
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
        
        let idToken = user.authentication.idToken // Safe to send to the server
        let email = user.profile.email
        
        print(idToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
}

// MARK: - Get Device Token
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        // Device Token을 keychain에 저장하기
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("등록 실패", error)
    }
}
