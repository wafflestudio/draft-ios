//
//  RoomGroup.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

/// Room group which appears in each tableView section
struct RoomGroup {
    private var roomGroup = [GameDate: [Room]]()

    init() {
        roomGroup = [sampleDate: [sampleRoom]]
    }
    
    lazy var keys = roomGroup.keys

    subscript(i: GameDate) -> [Room]? {
        guard let item = roomGroup[i] else { return nil }
        return item
    }
}

// sample data
private var sampleDate = Date()
private var sampleRoom = Room(name: "집앞 농구장에서 한 게임 해요" , date: Date(), maxNum: 4)


