//
//  Extenstion.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import Foundation

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

func returnCurrentDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    let dateString = formatter.string(from: date)
    return dateString
}

func sendServerCurrentDate(date: Date) -> String {
//    let formatter = DateFormatter()
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.timeZone = TimeZone.current
//    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//    let dateString = formatter.string(from: date)
//    return dateString
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    let dateString = formatter.string(from: date)
    return dateString

}
