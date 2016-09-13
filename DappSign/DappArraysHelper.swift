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
    
    internal class func downloadAllDappsInArray(dappArray: DappArray,
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
    
    internal class func downloadDappsInArray(
        dappArray: DappArray,
        notSwipedAndNotCreatedByUser user: PFUser,
        blockedUserIds: [String],
        completion: (dapps: [PFObject]? , error: NSError?) -> Void
    ) {
        self.downloadAllDappsInArray(dappArray) {
            (dapps: [PFObject]?, error: NSError?) -> Void in
            guard let allDapps = dapps else {
                completion(dapps: nil, error: error)
                
                return
            }
            
            self.downloadDappsSwipedByUser(user, completion: {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                guard let dappsSwipedByUser = dapps else {
                    completion(dapps: nil, error: error)
                    
                    return
                }
                
                let dappsNotSwipedByUser = self.dappsNotSwipedByUserWithAllDapps(allDapps,
                    andDappsSwipedByUser: dappsSwipedByUser
                )
                
                let dappsNotSwipedAndNotCreatedByUser = dappsNotSwipedByUser.filter({
                    dapp -> Bool in
                    let userID = dapp["userid"] as? String
                    
                    if user.objectId == userID {
                        return false
                    }
                    
                    return true
                })
                
                let filteredDapps = dappsNotSwipedAndNotCreatedByUser.filter({
                    (dapp: PFObject) -> Bool in
                    if let dappUserId = dapp["userid"] as? String {
                        if blockedUserIds.contains(dappUserId) {
                            return false
                        }
                        
                        return true
                    }
                    
                    return false
                })
                
                completion(dapps: filteredDapps, error: nil)
            })
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
                let dappObject = PFObject(outDataWithClassName: "Dapps", objectId: dappID)
                
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
    
    internal class func dappArrayForDappWithId(
        dappId: String,
        completion: (dappArray: DappArray?) -> Void
    ) {
        let dappArrays: [DappArray] = [ .Primary, .Secondary, .Introductory ]
        
        self.dappArrayForDappWithIdAux(dappId, dappArrays: dappArrays, completion: completion)
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
        
        ParseHelper.downloadAllObjectsWithQuery(dappsRelationQuery,
            downloadedObjects: [],
            completion: completion
        )
    }
    
    private class func downloadDappsSwipedByUser(user: PFUser,
        completion: (dapps: [PFObject]?, error: NSError?) -> Void
    ) {
        let dappsSwipedRelation = user.relationForKey("dappsSwiped")
        let dappsSwipedRelationQuery = dappsSwipedRelation.query()
        
        ParseHelper.downloadAllObjectsWithQuery(dappsSwipedRelationQuery,
            downloadedObjects: [],
            completion: completion
        )
    }
    
    private class func dappsNotSwipedByUserWithAllDapps(allDapps: [PFObject],
        andDappsSwipedByUser dappsSwipedByUser: [PFObject]
    ) -> [PFObject] {
        let dappsNotSwipedByUser = allDapps.filter {
            dapp -> Bool in
            if self.dapps(dappsSwipedByUser, containDappWithID: dapp.objectId) {
                return false
            }
            
            return true
        }
        
        return dappsNotSwipedByUser
    }
    
    private class func dapps(dapps: [PFObject], containDappWithID dappID: String) -> Bool {
        for dapp in dapps {
            if dapp.objectId == dappID {
                return true
            }
        }
        
        return false
    }
    
    internal class func dappArrayForDappWithIdAux(
        dappId: String,
        dappArrays: [DappArray],
        completion: (dappArray: DappArray?) -> Void
    ) {
        guard let dappArray = dappArrays.first else {
            completion(dappArray: nil)
            
            return
        }
        
        self.downloadAllDappsInArray(dappArray) {
            (dapps: [PFObject]?, error: NSError?) in
            if let dapps = dapps {
                for dapp in dapps {
                    if dapp.objectId == dappId {
                        completion(dappArray: dappArray)
                        
                        return
                    }
                }
            }
            
            self.dappArrayForDappWithIdAux(
                dappId,
                dappArrays: Array(dappArrays.dropFirst()),
                completion: completion
            )
        }
    }
}
