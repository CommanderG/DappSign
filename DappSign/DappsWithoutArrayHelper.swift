//
//  DappsWithoutArrayHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappsWithoutArrayHelper {
    internal class func downloadDappsWithoutArray(
        completion: (dappsWithoutArray: [PFObject]?, error: NSError?) -> Void
    ) {
        let allDappArrays: [DappArray] = [
            .Primary,
            .Secondary,
            .Introductory,
            .Scoreboard
        ]
        
        self.downloadDappsInArrays(allDappArrays, downloadedDapps: []) {
            (dappsInArrays: [PFObject]?, error: NSError?) -> Void in
            if let dappsInArrays = dappsInArrays {
                self.downloadAllDapps([], completion: {
                    (allDapps: [PFObject]?, error: NSError?) -> Void in
                    if let allDapps = allDapps {
                        let dappsWithoutArray = self.findDappsWithoutArrayInDappsInAllArrays(
                            dappsInArrays,
                            andAllDapps: allDapps
                        )
                        
                        completion(dappsWithoutArray: dappsWithoutArray, error: nil)
                    } else {
                        completion(dappsWithoutArray: nil, error: error)
                    }
                })
            } else {
                completion(dappsWithoutArray: nil, error: error)
            }
        }
    }
    
    // MARK: - private
    
    private class func downloadDappsInArrays(dappArrays: [DappArray],
        downloadedDapps: [PFObject],
        completion: (dappsInArrays: [PFObject]?, error: NSError?) -> Void
    ) {
        if let dappArray = dappArrays.first {
            DappArraysHelper.downloadDappsInArray(dappArray, completion: {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                if let dapps = dapps {
                    let remainingArrays = Array(dappArrays[1 ..< dappArrays.count])
                    
                    self.downloadDappsInArrays(remainingArrays,
                        downloadedDapps: downloadedDapps + dapps,
                        completion: completion
                    )
                } else {
                    completion(dappsInArrays: nil, error: error)
                }
            })
        } else {
            completion(dappsInArrays: downloadedDapps, error: nil)
        }
    }
    
    private class func downloadAllDapps(
        downloadedDapps: [PFObject],
        completion: (allDapps: [PFObject]?, error: NSError?) -> Void
    ) {
        let query = PFQuery(className: "Dapps")
        
        query.skip = downloadedDapps.count
        query.limit = 1000
        
        query.whereKey("isDeleted", notEqualTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let dapps = objects as? [PFObject] {
                if dapps.count > 0 {
                    self.downloadAllDapps(downloadedDapps + dapps, completion: completion)
                } else {
                    completion(allDapps: downloadedDapps, error: nil)
                }
            } else {
                completion(allDapps: nil, error: error)
            }
        }
    }
    
    private class func findDappsWithoutArrayInDappsInAllArrays(dappsInAllArrays: [PFObject],
        andAllDapps allDapps: [PFObject]
    ) -> [PFObject] {
        var dappsWithoutArray: [PFObject] = []
        
        for dapp in allDapps {
            var dappIsNotInAnyOfTheArrays = true
            
            for arrayDapp in dappsInAllArrays {
                if dapp.objectId == arrayDapp.objectId {
                    dappIsNotInAnyOfTheArrays = false
                    
                    break
                }
            }
            
            if dappIsNotInAnyOfTheArrays {
                dappsWithoutArray.append(dapp)
            }
        }
        
        return dappsWithoutArray
    }
}
