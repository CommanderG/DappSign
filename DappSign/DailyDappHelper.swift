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
    
    internal class func downloadDapps(
        dappsArrays: [DappArray],
        blockedUserIds: [String],
        completion: (dapps: [PFObject]) -> Void
    ) {
        self.downloadDappsHelper(
            dappsArrays,
            dappsArraysDapps: [:],
            blockedUserIds: blockedUserIds) {
                (dappsArraysDapps: [DappArray: [PFObject]]) -> Void in
                self.processAndJoinDapps(
                    dappsArraysDapps,
                    dappsArrays: dappsArrays,
                    dapps: [],
                    completion: completion
                )
        }
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
    
    private class func downloadDappsHelper(
        dappsArrays: [DappArray],
        dappsArraysDapps: [DappArray: [PFObject]],
        blockedUserIds: [String],
        completion: (dappArraysDapps: [DappArray: [PFObject]]) -> Void
    ) {
        guard let dappArray = dappsArrays.first else {
            completion(dappArraysDapps: dappsArraysDapps)
            
            return
        }
        
        let user = PFUser.currentUser()
        
        DappArraysHelper.downloadDappsInArray(
            dappArray,
            notSwipedAndNotCreatedByUser: user,
            blockedUserIds: blockedUserIds,
            completion: {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                guard let dapps = dapps else {
                    completion(dappArraysDapps: dappsArraysDapps)
                    
                    return
                }
                
                var newDappsArraysDapps = dappsArraysDapps
                
                newDappsArraysDapps[dappArray] = dapps
                
                let remainingDappsArrays = Array(dappsArrays.dropFirst())
                
                self.downloadDappsHelper(remainingDappsArrays,
                    dappsArraysDapps: newDappsArraysDapps,
                    blockedUserIds: blockedUserIds,
                    completion: completion
                )
        })
    }
    
    private class func processAndJoinDapps(
        dappsArraysDapps: [DappArray: [PFObject]],
        dappsArrays: [DappArray],
        dapps: [PFObject],
        completion: (dapps: [PFObject]) -> Void
    ) {
        if let dappsArray = dappsArrays.first, currentArrayDapps = dappsArraysDapps[dappsArray] {
            let remainingDappsArrays = Array(dappsArrays.dropFirst())
            
            self.processDapps(currentArrayDapps, dappsArray: dappsArray, completion: {
                (processedDapps: [PFObject]) -> Void in
                let newDapps = dapps + processedDapps
                
                self.processAndJoinDapps(dappsArraysDapps,
                    dappsArrays: remainingDappsArrays,
                    dapps: newDapps,
                    completion: completion
                )
            })
        } else {
            completion(dapps: dapps)
        }
    }
    
    private class func processDapps(dapps: [PFObject],
        dappsArray: DappArray,
        completion: (processedDapps: [PFObject]) -> Void
    ) {
        switch dappsArray {
        case .Secondary:
            DappsHelper.sortDappsByDappScore(dapps, completion: {
                (sortedDapps: [PFObject]) -> Void in
                let newDapps = dapps + sortedDapps
                
                completion(processedDapps: newDapps)
            })
            
            break
        case _:
            DappIndexHelper.downloadDappIndexesForArrayWithName(dappsArray.rawValue) {
                (dappIndexes: [DappIndex]?, error: NSError?) -> Void in
                if let dappIndexes = dappIndexes {
                    let orderedDapps = DappsHelper.orderDappsByIndex(dapps,
                        dappIndexes: dappIndexes,
                        dappArray: dappsArray
                    )
                    
                    completion(processedDapps: orderedDapps)
                } else {
                    completion(processedDapps: dapps)
                }
            }
            
            break
        }
    }
}
