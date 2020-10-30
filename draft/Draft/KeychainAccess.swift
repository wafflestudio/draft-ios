//
//  KeychainAccess.swift
//  draft
//
//  Created by JSKeum on 2020/08/29.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import KeychainAccess

class KeychainAccess {
    
    static let shared = KeychainAccess()
    private init() {}
    private let keychain = Keychain(service: "com.draft.waffle")
    
    func saveOAuthInKeychain(identifier: String, accessToken: Data, type: OAuthType) {
        let identifierKey = type.generateIdentifierKey().rawValue
        let accessTokenKey = type.generateAccessTokenKey().rawValue
        
        saveUserIdentifier(identifier: identifier, key: identifierKey)
        saveAccessToken(accessToken: accessToken, key: accessTokenKey)
    }
    
    private func saveUserIdentifier(identifier: String, key: String) {
        do {
            try keychain.set(identifier, key: key)
        } catch let error {
            debugPrint(error)
        }
    }
    
    private func saveAccessToken(accessToken: Data, key: String) {
        do {
            try keychain.set(accessToken, key: key)
        } catch let error {
            debugPrint(error)
        }
    }
    
    func getUserIdentifier(type: OAuthType) -> (identfier: String?, error: KeychainError?) {
        let key = type.generateIdentifierKey().rawValue
        do {
            if let identifier = try keychain.get(key) {
                return (identifier, nil)
            } else {
                return (nil, KeychainError.ValueNotFound)
            }
        } catch let error {
            debugPrint(error)
            return (nil, KeychainError.CannotGetKeychain)
        }
    }
    
    func getAccessToken(type: OAuthType) -> String {
        let key = type.generateAccessTokenKey().rawValue
        do {
            if let identifier = try keychain.get(key) {
                return identifier
            } else {
                return KeychainError.ValueNotFound.rawValue
            }
        } catch let error {
            debugPrint(error)
            return KeychainError.CannotGetKeychain.rawValue
        }
    }
}

enum OAuthType {
    case appleOAuth
    case googleOAuth
    case kakaoOAuth
    
    func generateAccessTokenKey() -> KeyType {
        switch self {
        case .appleOAuth:
            return KeyType.appleAccessToken
        case .googleOAuth:
            return KeyType.googleAccessToken
        case .kakaoOAuth:
            return KeyType.kakaoAccessToken
        }
    }
        
    func generateIdentifierKey() -> KeyType {
        switch self {
        case .appleOAuth:
            return KeyType.appleUserIdentifier
        case .googleOAuth:
            return KeyType.googleUserIdentifier
        case .kakaoOAuth:
            return KeyType.kakaoUserIdentifier
        }
    }
}

enum KeyType: String {
    case appleAccessToken = "AppleAccessTokenForDraft"
    case googleAccessToken = "GoogleAccessTokenForDraft"
    case kakaoAccessToken = "KakaoAccessTokenForDraft"
    case appleUserIdentifier = "AppleUserIdentifierForDraft"
    case googleUserIdentifier = "GoogleUserIdentifierForDraft"
    case kakaoUserIdentifier = "KakaoUserIdentifierForDraft"
}

enum KeychainError: String {
    case ValueNotFound = "ValueNotFound"
    case CannotGetKeychain = "CannotGetKeychain"
}
