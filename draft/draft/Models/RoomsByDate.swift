//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

/// Room group which appears in each tableView section
class RoomsByDate: Sequence, IteratorProtocol {
    
    private var rooms = [Room?]()
    private var date: GameDate = GameDate()
    
    var count: Int {
        get { return rooms.count }
    }

    subscript(i: Int) -> Room? {
        guard let item = rooms[i] else { return nil }
        return item
    }
    
    // add room test function
    func addRoom(room: Room) {
        rooms.append(room)
    }
    
    func getDateInString() -> String {
        return date.dateInString
    }
    
    // implement IteratorProtocol protocols to use 'for in RoomGroup'
    lazy private var _count = count
    func next() -> Room? {
        if _count == 0 {
            _count = count
            return nil
        } else {
            defer { _count -= 1 }
            return rooms[_count - 1]
        }
    }
}

// sample data
var sampleRoom = Room(name: "집 앞 농구장에서 한 게임 해요" , date: Date(), maxNum: 4)



