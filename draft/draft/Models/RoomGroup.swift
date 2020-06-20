//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/06/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation



struct RoomGroup {
    var roomGroup: [GameDate: RoomsByDate]
    
    func getNumOfRoomDate() -> Int {
        return roomGroup.keys.count
    }
}
