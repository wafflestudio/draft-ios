//
//  Room.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

/// Room model 
class Room {
    
    var name: String
    var date: GameTime
    var maxNumOfRoom: UInt
    var isClosed: Bool = false
    
    init(name: String, date: GameTime, maxNum maxNumOfRoom: UInt) {
        self.name = name
        self.date = date
        self.maxNumOfRoom = maxNumOfRoom
    }
}


