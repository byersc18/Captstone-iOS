//
//  HelperFunctions.swift
//  Bar Hopper
//
//  Created by Cameron Byers on 4/19/18.
//  Copyright © 2018 Cameron Byers. All rights reserved.
//

import Foundation

func parseTime(startDate: String, endDate: String) -> String {
    let startDateindex = startDate.index(startDate.startIndex, offsetBy: 5)
    let endDateindex = startDate.index(startDate.startIndex, offsetBy: 10)
    let startDateRange = startDateindex ..< endDateindex
    let sDate = startDate[startDateRange]
    
    let startTimeindex = startDate.index(startDate.startIndex, offsetBy: 11)
    let endTimeindex = startDate.index(startDate.startIndex, offsetBy: 16)
    let startTimeRange = startTimeindex ..< endTimeindex
    let sTime = startDate[startTimeRange]
    
    let eDate = endDate[startDateRange]
    let eTime = endDate[startTimeRange]
    return String(sDate) + " " + String(sTime) + " to " + String(eDate) + " " + String(eTime)
}
