//
//  Model-utilities.swift
//  draft
//
//  Created by JSKeum on 2020/06/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

// MARK: GameTime & GameDate
typealias GameTime = Date
typealias GameDate = Date

// MARK: Dateformat for section
extension Date {
    var dateInString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
