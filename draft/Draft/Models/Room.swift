//
//  Room.swift
//  draft
//
//  Created by JSKeum on 2020/05/03.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

struct Room: Decodable {
    let id: Int
    let roomStatus: String
    let startTime: String
    let endTime: String
    let name: String
    let createdAt: String?
    let ownerId: Int
    let courtId: Int
    let participants: [Participant]
}

struct Participant: Decodable {
    let id: Int
    let username: String
    let email: String
    let profileImage: String
}
