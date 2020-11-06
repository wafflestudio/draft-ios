//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/06/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

struct RoomList {
    var roomsByRegion = RoomsByRegion()
    var roomsByDate = RoomsByDate()
 
    mutating func sortByRegion(data: GetRoomByRegionResponseData) {
        roomsByRegion.region = data.depth1 ?? ""
        roomsByRegion.rooms = data.rooms
    }
}

struct RoomsByRegion {
    var region = ""
    var rooms = [Room]()
}

struct RoomsByDate {
    var rooms = [GameDate: [Room]]()
}
