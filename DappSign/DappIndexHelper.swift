//
//  DappArraysIndexes.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

struct DappIndex {
    let dappID: String
    let dappsArrayName: String
    let index: Int
}

class DappIndexHelper {
    private static let dappIndexClassName   = "DappIndex"
    private static let dappIDColumn         = "dappID"
    private static let dappsArrayNameColumn = "dappsArrayName"
    private static let indexColumn          = "index"
    
    internal class func downloadDappIndexes(
        completion: (dappIndexes: [DappIndex]?, error: NSError?) -> Void
    ) {
        let query = PFQuery(className: dappIndexClassName)
        
        self.downloadDappIndexesWithQuery(query, downloadedDappIndexes: [], completion: completion)
    }
    
    internal class func downloadDappIndexesForArrayWithName(arrayName: String,
        completion: (dappIndexes: [DappIndex]?, error: NSError?) -> Void
    ) {
        let query = PFQuery(className: dappIndexClassName)
        
        query.whereKey(dappsArrayNameColumn, equalTo: arrayName)
        
        self.downloadDappIndexesWithQuery(query, downloadedDappIndexes: [], completion: completion)
    }
    
    // MARK: - private
    
    private class func downloadDappIndexesWithQuery(query: PFQuery,
        downloadedDappIndexes: [DappIndex],
        completion: (dappIndexes: [DappIndex]?, error: NSError?) -> Void
    ) {
        query.skip = downloadedDappIndexes.count
        query.limit = 1000
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let dappIndexObjects = objects as? [PFObject] {
                if dappIndexObjects.count > 0 {
                    let dappIndexes = self.dappIndexesWithDappIndexObjects(dappIndexObjects)
                    
                    self.downloadDappIndexesWithQuery(query,
                        downloadedDappIndexes: downloadedDappIndexes + dappIndexes,
                        completion: completion
                    )
                } else {
                    completion(dappIndexes: downloadedDappIndexes, error: nil)
                }
            } else {
                completion(dappIndexes: nil, error: error)
            }
        }
    }
    
    private class func dappIndexesWithDappIndexObjects(
        dappIndexObjects: [PFObject]
    ) -> [DappIndex] {
        let dappIndexes = dappIndexObjects.map({
            (dappIndexObject: PFObject) -> DappIndex? in
            self.dappIndexWithDappIndexObject(dappIndexObject)
        }).filter ({
            (dappIndexOption: DappIndex?) -> Bool in
            if let _ = dappIndexOption {
                return true
            }
            
            return false
        }).map({
            (dappIndexOption: DappIndex?) -> DappIndex in
            dappIndexOption!
        })
        
        return dappIndexes
    }
    
    private class func dappIndexWithDappIndexObject(dappIndexObject: PFObject) -> DappIndex? {
        if let
            dappID = dappIndexObject[dappIDColumn] as? String,
            dappsArrayName = dappIndexObject[dappsArrayNameColumn] as? String,
            index = dappIndexObject[indexColumn] as? Int {
                let dappIndex = DappIndex(
                    dappID: dappID,
                    dappsArrayName: dappsArrayName,
                    index: index
                )
                
                return dappIndex
        }
        
        return nil
    }
}
