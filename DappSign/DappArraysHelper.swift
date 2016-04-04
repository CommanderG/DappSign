//
//  DappArrays.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappArraysHelper {
    private static let dappArraysClassName = "DappArrays"
    private static let dappsRelationKey = "dapps"
    private static let arrayNameKey = "arrayName"
    
    // MARK: - requests
    
    internal class func downloadDappsInArray(dappArray: DappArray,
        completion: (dapps: [PFObject]?, error: NSError?) -> Void
    ) {
        self.downloadDappArrayObject(dappArray) {
            (dappArrayObject: PFObject?, error: NSError?) -> Void in
            if let dappArrayObject = dappArrayObject {
                self.downloadDappsInDappArrayObject(dappArrayObject,
                    downloadedDapps: [],
                    completion: completion
                )
            } else {
                completion(dapps: nil, error: error)
            }
        }
    }
    
    internal class func addDapp(dapp: PFObject,
        toArray dappArray: DappArray,
        completion: (error: NSError?) -> Void
    ) {
        self.downloadDappArrayObject(dappArray) {
            (dappArrayObject: PFObject?, error: NSError?) -> Void in
            if let dappArrayObject = dappArrayObject {
                let dappsRelation = dappArrayObject.relationForKey(dappsRelationKey)
                
                dappsRelation.addObject(dapp)
                dappArrayObject.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        completion(error: nil)
                    } else {
                        completion(error: error)
                    }
                })
            } else {
                completion(error: error)
            }
        }
    }
    
    internal class func removeDapp(dapp: PFObject,
        fromArray dappArray: DappArray,
        completion: (error: NSError?) -> Void
    ) {
        self.downloadDappArrayObject(dappArray) {
            (dappArrayObject: PFObject?, error: NSError?) -> Void in
            if let dappArrayObject = dappArrayObject {
                let dappsRelation = dappArrayObject.relationForKey(dappsRelationKey)
                
                dappsRelation.removeObject(dapp)
                dappArrayObject.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        completion(error: nil)
                    } else {
                        completion(error: error)
                    }
                })
            } else {
                completion(error: error)
            }
        }
    }
    
    internal class func countDappsInArray(dappArray: DappArray,
        completion: (dappsCount: Int32?, error: NSError?) -> Void
    ) {
        self.downloadDappArrayObject(dappArray) {
            (dappArrayObject: PFObject?, error: NSError?) -> Void in
            if let dappArrayObject = dappArrayObject {
                let dappsRelation = dappArrayObject.relationForKey(dappsRelationKey)
                let dappsRelationQuery = dappsRelation.query()
                
                dappsRelationQuery.countObjectsInBackgroundWithBlock({
                    (count: Int32, error: NSError?) -> Void in
                    completion(dappsCount: count, error: error)
                })
            } else {
                completion(dappsCount: nil, error: error)
            }
        }
    }
    
    internal class func removeDappWithID(dappID: String,
        fromArray dappArray: DappArray,
        completion: (error: NSError?) -> Void
    ) {
        self.downloadDappArrayObject(dappArray) {
            (dappArrayObject: PFObject?, error: NSError?) -> Void in
            if let dappArrayObject = dappArrayObject {
                let dappsRelation = dappArrayObject.relationForKey(dappsRelationKey)
                let dappObject = PFObject(withoutDataWithClassName: "Dapps", objectId: dappID)
                
                dappsRelation.removeObject(dappObject)
                dappArrayObject.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    completion(error: error)
                })
            } else {
                completion(error: error)
            }
        }
    }
    
    // MARK: - private
    
    private class func downloadDappArrayObject(
        dappArray: DappArray,
        completion: (dappArrayObject: PFObject?, error: NSError?) -> Void
    ) {
        let query = PFQuery(className: dappArraysClassName)
        
        query.whereKey(arrayNameKey, equalTo: dappArray.rawValue)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let dappArrayObject = objects?.first as? PFObject {
                completion(dappArrayObject: dappArrayObject, error: nil)
            } else {
                completion(dappArrayObject: nil, error: error)
            }
        }
    }
    
    private class func downloadDappsInDappArrayObject(dappArrayObject: PFObject,
        downloadedDapps: [PFObject],
        completion: (dapps: [PFObject]?, error: NSError?) -> Void
    ) {
        let dappsRelation = dappArrayObject.relationForKey(dappsRelationKey)
        let dappsRelationQuery = dappsRelation.query()
        
        dappsRelationQuery.skip = downloadedDapps.count
        dappsRelationQuery.limit = 1000
        
        dappsRelationQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let dapps = objects as? [PFObject] {
                if dapps.count > 0 {
                    self.downloadDappsInDappArrayObject(dappArrayObject,
                        downloadedDapps: downloadedDapps + dapps,
                        completion: completion
                    )
                } else {
                    completion(dapps: downloadedDapps, error: error)
                }
            } else {
                completion(dapps: downloadedDapps, error: error)
            }
        }
    }
}
