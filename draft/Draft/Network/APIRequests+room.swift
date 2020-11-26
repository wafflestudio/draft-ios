//
//  APIRequests+user.swift
//  Draft
//
//  Created by JSKeum on 2020/10/30.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation
import Alamofire

enum RoomRequestType {
    case getRoomsByRegion
    case getSingleRoom
    case getSearchedRooms
}

struct roomSearchQueryParameter: Encodable {
    
}

struct GetRoomByRegionResponseData: Decodable {
    let id: Int
    let name: String
    let depth1: String?
    let depth2: String?
    let depth3: String?
    let rooms: [Room]
}

struct GetRoomBySearchResponseData: Decodable {
    let count: Int
    let result: SearchedRoomData
    let next: Int
}

struct SearchedRoomData: Decodable {
    let id: Int
    let name: String
    let depth1: String
    let depth2: String
    let depth3: String
    let rooms: [Room]
}

enum RoomRequestError {
    case responseDataNotFound
    case responseError
}

extension APIRequests {
    func requestRoom(requestType: RoomRequestType, parameters: [String:Any]? = nil, completion: @escaping (_ data: Any?, _ error: RoomRequestError?) -> Void) {
            switch requestType {
            case .getRoomsByRegion:
                AF.request(APIUrl.getRoomUrl,
                           method: .get,
                           headers: oauthTokenHeader)
                    .validate().responseJSON() { res in
                        switch res.result {
                        case .success:
                        if let data = res.data {
                            do {
                                let decodedData = try   JSONDecoder().decode(GetRoomBySearchResponseData.self, from: data)
                                completion(decodedData, nil)
                            } catch let error {
                                debugPrint(error)
                                completion(nil, .responseDataNotFound)
                            }
                        }
                            
                        case let .failure(error):
                            debugPrint(error)
                            completion(nil, .responseError)
                        }
                }
            case .getSingleRoom:
                    #warning("TODO")
            case .getSearchedRooms:
                AF.request(APIUrl.searchRoomUrl,
                           method: .post,
                           parameters: parameters,
                           headers: oauthTokenHeader)
                    .validate().responseJSON() { response in
                        switch response.result {
                        case .success:
                        if let data = response.data {
                            do {
                                let decodedData = try   JSONDecoder().decode(Array<GetRoomByRegionResponseData>.self, from: data)
                                completion(decodedData[0], nil)
                            } catch let error {
                                debugPrint(error)
                                completion(nil, .responseDataNotFound)
                            }
                        }
                            
                        case let .failure(error):
                            debugPrint(error)
                            completion(nil, .responseError)
                        }
            }
        }
    }
}
