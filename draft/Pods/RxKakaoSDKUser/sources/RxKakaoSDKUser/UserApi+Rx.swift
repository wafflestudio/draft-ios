//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

import RxSwift
import Alamofire
import RxAlamofire

import KakaoSDKCommon
import RxKakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser

let auth = Auth.shared
let api = Api.shared

extension UserApi: ReactiveCompatible {}

/// `UserApi`의 ReactiveX 확장입니다.
///
/// 아래는 user/me를 호출하는 간단한 예제입니다.
///
///     UserApi.shared.rx.me()
///        .subscribe(onSuccess:{ (user) in
///            print(user)
///        }, onError: { (error) in
///            print(error)
///        })
///        .disposed(by: <#Your DisposeBag#>)
extension Reactive where Base: UserApi {
    
    // MARK: API Methods
    
    /// 사용자에 대한 다양한 정보를 얻을 수 있습니다.
    /// - seealso: `User`
    public func me(propertyKeys: [String]? = nil,
                   secureResource: Bool = true) -> Single<User> {        
        return auth.rx.responseData(.get, Urls.compose(path:Paths.userMe),
                                 parameters: ["propertyKeys": propertyKeys,
                                              "secure_resource": secureResource].filterNil())
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            })
            .compose(api.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// User 클래스에서 제공되고 있는 사용자의 부가정보를 신규저장 및 수정할 수 있습니다.
    ///
    /// 저장 가능한 키 이름은 개발자사이트 앱 설정의 `사용자 관리 > 사용자 목록 및 프로퍼티` 메뉴에서 확인하실 수 있습니다. 앱 연결 시 기본 저장되는 nickanme, profile_image, thumbnail_image 값도 덮어쓰기 가능하며
    /// 새로운 컬럼을 추가하면 해당 키 이름으로 값을 저장할 수 있습니다.
    /// - seealso: `User.properties`
    public func updateProfile(properties: [String:Any]) -> Completable {
        return auth.rx.responseData(.post, Urls.compose(path:Paths.userUpdateProfile),
                                 parameters: ["properties": properties.toJsonString()].filterNil())
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .do (
                onNext: { _ in
                    SdkLog.i("completable:\n success\n\n" )
                }
            )
            .ignoreElements()
    }
    
    /// 현재 토큰의 기본적인 정보를 조회합니다. me()에서 제공되는 다양한 사용자 정보 없이 가볍게 토큰의 유효성을 체크하는 용도로 사용하는 경우 추천합니다.
    /// - seealso: `AccessTokenInfo`
    public func accessTokenInfo() -> Single<AccessTokenInfo> {
        return auth.rx.responseData(.get, Urls.compose(path:Paths.userAccessTokenInfo))
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(api.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 토큰을 강제로 만료시킵니다. 같은 사용자가 여러개의 토큰을 발급 받은 경우 로그아웃 요청에 사용된 토큰만 만료됩니다.
    public func logout() -> Completable {
        return auth.rx.responseData(.post, Urls.compose(path:Paths.userLogout))
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .ignoreElements()
            .do(onCompleted:{
                auth.tokenManager.deleteToken()
            })
    }
    
    /// 카카오 플랫폼 서비스와 앱 연결을 해제합니다.
    public func unlink() -> Completable {
        return auth.rx.responseData(.post, Urls.compose(path:Paths.userUnlink))
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .ignoreElements()
            .do(onCompleted: {
                auth.tokenManager.deleteToken()
            })
    }
    
    /// 앱에 가입한 사용자의 배송지 정보를 얻어간다.
    /// - seealso: `UserShippingAddresses`
    public func shippingAddresses(fromUpdatedAt: Int? = nil, pageSize: Int? = nil) -> Single<UserShippingAddresses> {
        return auth.rx.responseData(.get, Urls.compose(path:Paths.userShippingAddress),
                                 parameters: ["from_updated_at": fromUpdatedAt, "page_size": pageSize].filterNil())
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customSecondsSince1970, response, data)
            })
            .compose(api.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 앱에 가입한 사용자의 배송지 정보를 얻어간다.
    /// - seealso: `UserShippingAddresses`
    public func shippingAddresses(addressId: Int64) -> Single<UserShippingAddresses> {
        return auth.rx.responseData(.get, Urls.compose(path:Paths.userShippingAddress),
                                 parameters: ["address_id": addressId].filterNil())
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customSecondsSince1970, response, data)
            })
            .compose(api.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 사용자가 카카오 간편가입을 통해 동의한 서비스 약관 내역을 반환합니다.
    /// - seealso: `UserServiceTerms`
    public func serviceTerms() -> Single<UserServiceTerms> {
        return auth.rx.responseData(.get, Urls.compose(path:Paths.userServiceTerms))
            .compose(auth.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            })
            .compose(api.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
//    public func ageAuth() -> Single<AgeAuth> {
//        return Api.shared.responseData(.get, Urls.userServiceTerms)
//            .compose(composeTransformerCheckApiErrorForKApi)
//            .map({ (response, data) -> UserServiceTerms in
//                return try SdkJSONDecoder.custom.decode(UserServiceTerms.self, from: data)
//            })
//            .asSingle()
//    }
}

