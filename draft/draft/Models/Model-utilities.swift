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
typealias GameDateString = String

// MARK: Dateformat for section
extension Date {
    var dateToStringAsYMD: String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var dateToStringAsYMDHM: String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var dateToStringAsYMDHMS: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH':'mm':'ss"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension String {
    var stringToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH':'mm':'ss"
        let date = dateFormatter.date(from: self)
        return date
    }
    
    var timeStringToDateString: String? {
        let date = self.stringToDate
        let dateString = date?.dateToStringAsYMD
        
        return dateString
    }
}

