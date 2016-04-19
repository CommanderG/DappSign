//
//  ScoreboardHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/14/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class ScoreboardHelper {
    internal class func downloadScoreboardDapps(
        completion: (scoreboardDapps: [PFObject], error: NSError?) -> Void
    ) {
        self.downloadTop10DailyDapps {
            (top10DailyDapps: [PFObject], error: NSError?) -> Void in
            if let error = error {
                completion(scoreboardDapps: [], error: error)
                
                return
            }
            
            DappArraysHelper.downloadAllDappsInArray(.Scoreboard) {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                if let dapps = dapps {
                    let scoreboardDapps = top10DailyDapps + dapps
                    
                    completion(scoreboardDapps: scoreboardDapps, error: nil)
                } else {
                    completion(scoreboardDapps: top10DailyDapps, error: error)
                }
            }
        }
    }
    
    // MARK: - private
    
    private class func downloadTop10DailyDapps(
        completion: (top10DailyDapps: [PFObject], error: NSError?) -> Void
    ) {
        let dateString = self.currentDateString()
        
        DailyDappHelper.findDailyDappWithDate(dateString) {
            (dailyDapp: PFObject?, error: NSError?) -> Void in
            if let dailyDapp = dailyDapp {
                DailyDappHelper.downloadDappsInDailyDapp(dailyDapp, completion: {
                    (dapps: [PFObject], error: NSError?) -> Void in
                    if let error = error {
                        completion(top10DailyDapps: [], error: error)
                        
                        return
                    }
                    
                    DappsHelper.sortDappsByDappScore(dapps, completion: {
                        (sortedDapps: [PFObject]) -> Void in
                        let top10Dapps = first(10, objects: sortedDapps)
                        
                        completion(top10DailyDapps: top10Dapps, error: nil)
                    })
                })
            } else {
                completion(top10DailyDapps: [], error: error)
            }
        }
    }
    
    private class func currentDateString() -> String {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    private class func first<T>(count: Int, objects: [T]) -> [T] {
        if objects.count < count {
            return objects
        }
        
        return Array(objects[0 ..< count])
    }
}
