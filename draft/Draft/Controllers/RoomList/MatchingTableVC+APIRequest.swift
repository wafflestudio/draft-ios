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
        APIRequests.shared.requestRoom(requestType: .getRoomsByRegion) { (data, error) in
            if let data = data {
                self.roomList.sortByRegion(data: data as! GetRoomByRegionResponseData)
                self.tableView.reloadData()
            }
            
            if let error = error {
                #warning("TODO: 에러 처리")
            }
        }
    }
}
