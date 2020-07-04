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

/// 앱에 가입한 사용자의 배송지 정보 API 응답 클래스
/// - seealso: `UserApi.shippingAddresses(fromUpdatedAt:pageSize:)` <br>`UserApi.shippingAddresses(addressId:)`
///
/// 배송지의 정렬 순서는 기본배송지가 무조건 젤 먼저, 그후에는 배송지 수정된 시각을 기준으로 최신순으로 정렬되어 나가고, 페이지 사이즈를 주어서 여러 페이지를 나누어 조회하거나, 특정 배송지 아이디만을 지정하여 해당 배송지 정보만을 조회할 수 있습니다.
public struct UserShippingAddresses : Codable {
    
    // MARK: Fields
    
    /// 사용자 아이디
    public let userId: Int64
    
    /// 배송지 제공에 대한 사용자의 동의 필요 여부
    public let needsAgreement: Bool
    
    /// 사용자가 소유한 배송지 목록
    ///
    /// 가장 최근 수정했던 순으로 정렬됩니다. (단, 기본 배송지는 수정시각과 상관없이 첫번째에 위치) shippingAddresses는 사용자의 동의를 받지 않은 경우 nil이 반환됩니다. shippingAddresses가 nil이면 needsAgreement 속성 값을 확인하여 사용자에게 정보 제공에 대한 동의를 요청하고 정보 획득을 시도해 볼 수 있습니다.
    /// - seealso: `ShippingAddress`
    public let shippingAddresses: [ShippingAddress]?
    
    
    enum CodingKeys: String, CodingKey {
        case userId, shippingAddresses
        case needsAgreement = "shippingAddressesNeedsAgreement"
    }
}


/// 배송지 정보 클래스
/// - seealso: `UserShippingAddresses`
public struct ShippingAddress : Codable {
    
    // MARK: Enumerations
    
    /// 배송지 타입 열거형
    public enum `Type` : String, Codable {
        /// 지번 주소
        case Old = "OLD"
        /// 도로명 주소
        case New = "NEW"
    }
    
    // MARK: Fields
    
    /// 배송지 아이디
    public let id: Int64
    
    /// 배송지명
    public let name: String?
    
    /// 기본 배송지 여부
    public let isDefault: Bool
    
    /// 마지막 배송지정보 수정시각
    public let updatedAt: Date
    
    /// 배송지 타입
    /// - seealso: Type
    public let type: Type
    
    /// 우편번호 검색시 채워지는 기본 주소
    public let baseAddress: String
    
    /// 기본 주소에 추가하는 상세 주소
    public let detailAddress: String
    
    /// 수령인 이름
    public let receiverName: String?
    
    /// 수령인 연락처
    public let receiverPhoneNumber1: String?
    
    /// 수령인 추가 연락처
    public let receiverPhoneNumber2: String?
    
    /// 도로명 주소 우편번호. 배송지 타입이 NEW인 경우 반드시 존재함
    public let zoneNumber: String?
    
    /// 지번 주소 우편번호. 배송지 타입이 OLD여도 값이 없을 수 있음
    public let zipCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, updatedAt, type, baseAddress, detailAddress, receiverName, receiverPhoneNumber1, receiverPhoneNumber2, zoneNumber, zipCode
        case isDefault = "default"
    }
}
