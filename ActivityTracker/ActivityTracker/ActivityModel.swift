//
//  ActivityModel.swift
//  ActivityTracker
//
//  Created by Rahul on 04/07/24.
//

import Foundation

struct ActivityModel: Codable {
    let activityName: String
    let activities: [String]
//    let date: Int64
//    let dateFormated: String
    let isNeedToConsiderSorting: Bool
//    let selectedActivity: String
}
