//
//  DateHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/4/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DateHelper {
    internal class func dateWithDaysAddedToDate(date: NSDate, days: Int) -> NSDate {
        let minuteInSeconds = 60
        let hourInSecounds  = minuteInSeconds * 60
        let dayInSeconds    = hourInSecounds * 24
        let timeInterval    = NSTimeInterval(dayInSeconds * days)
        let newDate         = date.dateByAddingTimeInterval(timeInterval)
        
        return newDate
    }
    
    internal class func fullHoursAndFullMinutesInTimeInterval(
        timeInterval: NSTimeInterval
    ) -> (Int, Int) {
        let minuteInSeconds    = 60.0
        let hourInSecounds     = minuteInSeconds * 60.0
        let hours              = timeInterval / hourInSecounds
        let (fullHours, _)     = modf(hours)
        let fullHoursInSeconds = fullHours * hourInSecounds
        let minutes            = (timeInterval - fullHoursInSeconds) / minuteInSeconds
        let (fullMinutes, _)   = modf(minutes)
        
        return (Int(fullHours), Int(fullMinutes))
    }
}