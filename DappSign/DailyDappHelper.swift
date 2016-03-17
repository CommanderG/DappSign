//
//  DailyDappHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/9/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DailyDappHelper {
    private static let dailyDappClass   = "DailyDapp"
    private static let dateKey          = "date"
    private static let dappsRelationKey = "dapps"
    
    internal class func addDapp(
        dapp: PFObject,
        completion: (error: NSError?) -> Void
    ) {
        let dateString = self.currentDateString()
        
        self.findDailyDappWithDate(dateString) {
            (dailyDapp: PFObject?, error: NSError?) -> Void in
            if let dailyDapp = dailyDapp {
                self.addDapp(dapp, toDailyDapp: dailyDapp, completion: completion)
            } else if let error = error {
                completion(error: error)
            } else {
                self.addDailyDappWithDate(dateString) {
                    (dailyDapp: PFObject?, error: NSError?) -> Void in
                    if let dailyDapp = dailyDapp {
                        self.addDapp(dapp, toDailyDapp: dailyDapp, completion: completion)
                    } else {
                        completion(error: error)
                    }
                }
            }
        }
    }
    
    internal class func findDailyDappWithDate(date: String,
        completion: (dailyDapp: PFObject?, error: NSError?) -> Void
    ) {
        let query = PFQuery(className: dailyDappClass)
        
        query.whereKey(dateKey, equalTo: date)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            let dailyDapp = objects?.first as? PFObject
            
            completion(dailyDapp: dailyDapp, error: error)
        }
    }
    
    internal class func downloadDappsInDailyDapp(dailyDapp: PFObject,
        completion: (dapps: [PFObject], error: NSError?) -> Void
    ) {
        let dappsRelation = dailyDapp.relationForKey(dappsRelationKey)
        let query = dappsRelation.query()
        
        query.limit = 1000
        
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let dailyDappDapps = objects as? [PFObject] {
                completion(dapps: dailyDappDapps, error: nil)
            } else {
                completion(dapps: [], error: error)
            }
        })
    }
    
    // MARK: - private
    
    private class func currentDateString() -> String {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    private class func addDapp(
        dapp: PFObject,
        toDailyDapp dailyDapp: PFObject,
        completion: (error: NSError?) -> Void
    ) {
        let dappsRelation = dailyDapp.relationForKey(dappsRelationKey)
        
        dappsRelation.addObject(dapp)
        
        dailyDapp.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(error: nil)
            } else {
                completion(error: error)
            }
        }
    }
    
    private class func addDailyDappWithDate(
        date: String,
        completion: (dailyDapp: PFObject?, error: NSError?) -> Void
    ) {
        let dailyDapp = PFObject(className: dailyDappClass)
        
        dailyDapp[dateKey] = date
        
        dailyDapp.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(dailyDapp: dailyDapp, error: nil)
            } else {
                completion(dailyDapp: nil, error: error)
            }
        }
    }
}
