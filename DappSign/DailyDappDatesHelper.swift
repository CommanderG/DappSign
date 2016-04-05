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
    
    internal class func timeIntervalUntilNextDailyDappStartDate() -> NSTimeInterval? {
        let currentDate = NSDate()
        
        if let nextDailyDappStartDate = self.nextDailyDappStartDate() {
            let timeInterval = nextDailyDappStartDate.timeIntervalSinceDate(currentDate)
            
            return timeInterval
        }
        
        return nil
    }
    
    internal class func timeIntervalBeforeCurrentDailyDappEnd() -> NSTimeInterval? {
        let currentDate = NSDate()
        
        if let currentDailyDappStartDate = self.startDateWithDate(currentDate) {
            let timeIntervalBeforeCurrentDailyDappEnd =
            currentDailyDappStartDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
            
            let oneHour = 1.0 * 60.0 * 60.0
            
            if timeIntervalBeforeCurrentDailyDappEnd > 0.0 &&
                timeIntervalBeforeCurrentDailyDappEnd <= oneHour {
                    return timeIntervalBeforeCurrentDailyDappEnd
            }
            
            return 0.0
        }
        
        return nil
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
    
    private class func nextDailyDappStartDate() -> NSDate? {
        let currentDate = NSDate()
        
        if let todayDailyDappStartDate = self.startDateWithDate(currentDate) {
            let todayDailyDappHasNotBegun =
            todayDailyDappStartDate.timeIntervalSince1970 > currentDate.timeIntervalSince1970
            
            if todayDailyDappHasNotBegun {
                return todayDailyDappStartDate
            } else {
                let tomorrowDailyDappStartDate =
                DateHelper.dateWithDaysAddedToDate(todayDailyDappStartDate, days: 1)
                
                return tomorrowDailyDappStartDate
            }
        }
        
        return nil
    }
}
