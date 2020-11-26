//
//  RoomSearchViewModel.swift
//  Draft
//
//  Created by Han Sang Hyeon - Ethan on 2020/11/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//
import RxSwift

class RoomSearchViewModel {
    var searchedRooms: Observable<[Room]>? = nil
    
    func getSearchResult(name: String? = nil, regionId: Int64? = nil, startTime: String? = nil, endTime: String? = nil) {
        
        var parameters: [String:Any] = [:]
        if name != nil {
            parameters["name"] = name
        }
        if regionId != nil {
            parameters["regionId"] = regionId
        }
        if startTime != nil {
            parameters["startTime"] = startTime
        }
        if endTime != nil {
            parameters["endTime"] = endTime
        }
        
        APIRequests.shared.requestRoom(requestType: .getSearchedRooms, parameters: parameters) { [weak self] (data, error) in
            guard let strongSelf = self, error == nil, let data = data as? GetRoomBySearchResponseData else {
                print("Search Error Occured")
                return
            }
            
            strongSelf.searchedRooms = Observable.of(data.result.rooms)
        }
    }
}
