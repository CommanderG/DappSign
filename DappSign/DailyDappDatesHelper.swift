//
//  DailyDappDatesHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/4/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DailyDappDatesHelper {
    internal class func startDateWithDate(date: NSDate) -> NSDate? {
        let startDate = self.dateWithDate(date, withHour: 12)
        
        return startDate
    }
    
    internal class func endDateWithDate(date: NSDate) -> NSDate? {
        let endDate = self.dateWithDate(date, withHour: 13)
        
        return endDate
    }
    
    // MARK: - 
    
    private class func dateWithDate(date: NSDate, withHour hour: Int) -> NSDate? {
        if hour < 0 || hour > 23 {
            return nil
        }
        
        let currentCalendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let components = currentCalendar.components(unitFlags, fromDate: date)
        
        components.hour   = hour
        components.minute = 0
        components.second = 0
        
        let newDate = currentCalendar.dateFromComponents(components)
        
        return newDate
    }
}
