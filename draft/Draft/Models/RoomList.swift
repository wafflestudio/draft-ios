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
        roomsByRegion.region = data.results[0].depth3 ?? ""
        roomsByRegion.rooms = data.results[0].rooms
    }
}

struct RoomsByRegion {
    var region = ""
    var rooms = [Room?]()
}

struct RoomsByDate {
    var rooms = [GameDate: [Room]]()
}
