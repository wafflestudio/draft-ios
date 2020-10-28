//
//  MatchingTableVC+APIRequest.swift
//  draft
//
//  Created by JSKeum on 2020/07/08.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

// MARK:- Call Rest API to get rooms from server
extension MatchingTableViewController {
    func getRoomsByRegion() {
        APIRequests.shared.request(param: nil, requestType: .getRoomsByRegion) { data in
            guard let data = data else {
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(Array<GetRoomByRegionResponseData>.self, from: data)
                self.roomGroup = RoomGroup(rooms: decodedData[0].rooms)
            } catch {
                #warning("TODO: 에러 처리")
            }
            self.tableView.reloadData()
        }
    }
}
