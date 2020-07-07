//
//  Room.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

class Room: Decodable {
    
    let id: Int
    let roomStatus: String
    let startTime: String
    let endTime: String
    let createdAt: String
    let ownerId: Int
    let name: String
}




