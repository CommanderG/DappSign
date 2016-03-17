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
        date: String,
        completion: (scoreboardDapps: [PFObject], error: NSError?) -> Void
    ) {
        DailyDappHelper.findDailyDappWithDate(date) {
            (dailyDapp: PFObject?, error: NSError?) -> Void in
            if let dailyDapp = dailyDapp {
                DailyDappHelper.downloadDappsInDailyDapp(dailyDapp, completion: {
                    (dapps: [PFObject], error: NSError?) -> Void in
                    if let error = error {
                        completion(scoreboardDapps: [], error: error)
                    } else {
                        DappsHelper.sortDappsByDappScore(dapps, completion: {
                            (sortedDapps: [PFObject]) -> Void in
                            let top10Dapps = first(10, objects: sortedDapps)
                            
                            completion(scoreboardDapps: top10Dapps, error: nil)
                        })
                    }
                })
            } else if let error = error {
                completion(scoreboardDapps: [], error: error)
            }
        }
    }
    
    // MARK: - private
    
    private class func first<T>(count: Int, objects: [T]) -> [T] {
        if objects.count < count {
            return objects
        }
        
        return Array(objects[0 ..< count])
    }
}
