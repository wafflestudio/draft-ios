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
}

struct GetRoomByRegionResponseData: Decodable {
    let results: [RoomResults]
    let count: Int
}

struct RoomResults: Decodable {
    let id: Int
    let name: String?
    let depth1: String?
    let depth2: String?
    let depth3: String?
    let rooms: [Room]
}

enum RoomRequestError {
    case responseDataNotFound
    case responseError
}

extension APIRequests {
    func requestRoom(requestType: RoomRequestType, completion: @escaping (_ data: GetRoomByRegionResponseData?, _ error: RoomRequestError?) -> Void) {
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
                                let decodedData = try JSONDecoder().decode(GetRoomByRegionResponseData.self, from: data)
                                debugPrint(decodedData)
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
            }
        }
}
