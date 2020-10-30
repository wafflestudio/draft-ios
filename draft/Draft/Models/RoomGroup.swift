//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/06/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

struct RoomGroup {
    var roomGroup = [GameDateString: RoomsByDate]()
    
    init?(rooms: [Room]) {
        for room in rooms {
            if let gameDay = room.startTime.timeStringToDateString {
                if let roomsByDate = roomGroup[gameDay] {
                    roomsByDate.addRoom(room: room)
                } else {
                roomGroup[gameDay] = RoomsByDate(room: room)
                }
            } else {
                print("Start Time is Null of Room(id:\(room.id))")
            }
        }
    }
    
    func getNumOfRoomDate() -> Int {
        return roomGroup.keys.count 
    }
}
