//
//  KeychainAccess.swift
//  draft
//
//  Created by JSKeum on 2020/08/29.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import KeychainAccess

/// Use KeychainAccess library by singleton class
class KeychainAccess {
    
    static let shared = KeychainAccess()
    
    private init() {}
    
    private let keychain = Keychain(service: "com.draft.waffle")
    
    func saveAppleLoginUserIdentifier(identifier: String) {
        do {
            try keychain.set(identifier, key: Key.AppleLoginUserIdentifier)
        } catch let error {
            print("keychain.set failed. Reson below :")
            print(error)
            
        }
    }
    
    func saveAppleLoginAccessToken(accessToken: Data) {
        do {
            try keychain.set(accessToken, key: Key.AppleLoginAccessToken)
        } catch let error {
            print("keychain.set failed. Reson below :")
            print(error)
            
        }
    }
    
    func getAppleLoginUserIdentifier() -> String {
        do {
            if let identifier = try keychain.get(Key.AppleLoginUserIdentifier) {
                return identifier
            } else {
                return KeychainError.ValueNotFound
            }
        } catch let error {
            print("error: \(error)")
            return KeychainError.CannotGetKeychain
        }
    }
    
    func getAppleLoginAccessToken() -> String {
        do {
            if let identifier = try keychain.get(Key.AppleLoginAccessToken) {
                return identifier
            } else {
                return KeychainError.ValueNotFound
            }
        } catch let error {
            print("error: \(error)")
            return KeychainError.CannotGetKeychain
        }
    }
}

struct Key {
    
    static let AppleLoginAccessToken = "AppleLoginAccessTokenForDraft"
    static let AppleLoginUserIdentifier = "AppleLoginUserIdentifierForDraft"
    static let AppleLoginAccessTokenValueNotFound = "ValueNotFound"
}

struct KeychainError {
    
    static let ValueNotFound = "ValueNotFound"
    static let CannotGetKeychain = "CannotGetKeychain"
}
