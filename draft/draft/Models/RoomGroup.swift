//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

/// Room group which appears in each tableView section
class RoomGroup {
    
    private var rooms = [Room?]()
    private var date: GameDate
    
    init() {
        self.rooms.append(sampleRoom)
        self.date = sampleDate
    }
    
    var count: Int {
        get { return rooms.count }
    }

    subscript(i: Int) -> Room? {
        guard let item = rooms[i] else { return nil }
        return item
    }
    
    // add room test function
    func addRoomToFirstGameDate(room: Room) {
        rooms.append(room)
    }
}

// sample data
private var sampleDate = Date()
var sampleRoom = Room(name: "집앞 농구장에서 한 게임 해요" , date: Date(), maxNum: 4)


