//
//  FlaggedPetitionsHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class FlaggedPetitionsHelper: NSObject {
    private static let flaggedPetitionClassName = "FlaggedPetition"
    
    internal class func flagPetition(petition: PFObject, completion: (success: Bool) -> Void) {
        self.flaggedPetitions {
            (petitions: [PFObject]?) in
            guard let flaggedPetitions = petitions else {
                return
            }
            
            for flaggedPetition in flaggedPetitions {
                if flaggedPetition.objectId == petition.objectId {
                    completion(success: true)
                    
                    return
                }
            }
            
            let flaggedPetition = PFObject(className: flaggedPetitionClassName)
            
            flaggedPetition["petition"] = petition
            
            flaggedPetition.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) in
                completion(success: success)
                
                if let error = error {
                    print("Failed to flag petition. Error: \(error)")
                }
            }
        }
    }
    
    internal class func flaggedPetitionsCount(completion: (count: Int32) -> Void) {
        let query = PFQuery(className: flaggedPetitionClassName)
        
        query.limit = 1000
        
        query.countObjectsInBackgroundWithBlock {
            (count: Int32, error: NSError?) in
            if let error = error {
                completion(count: 0)
                
                print("Failed to count flagged petitions. Error: \(error)")
            } else {
                completion(count: count)
            }
        }
    }
    
    internal class func flaggedPetitions(completion: (petitions: [PFObject]?) -> Void) {
        let query = PFQuery(className: flaggedPetitionClassName)
        
        query.limit = 1000
        
        query.includeKey("petition")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            if let flaggedPetitionObjs = objects as? [PFObject] {
                let petitions = flaggedPetitionObjs.map({
                    (flaggedPetitionObj: PFObject) -> PFObject? in
                    return flaggedPetitionObj["petition"] as? PFObject
                }).filter({
                    (petition: PFObject?) -> Bool in
                    if let _ = petition {
                        return true
                    }
                    
                    return false
                }).map({
                    (petition: PFObject?) -> PFObject in
                    return petition!
                })
                
                completion(petitions: petitions)
            } else {
                completion(petitions: nil)
            }
        }
    }
    
    internal class func deleteObjectWithDappId(
        dappId: String,
        completion: (error: NSError?) -> Void
    ) {
        let query = PFQuery(className: flaggedPetitionClassName)
        
        query.limit = 1000
        
        query.includeKey("petition")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            guard let flaggedPetitions = objects as? [PFObject] else {
                completion(error: error)
                
                return
            }
            
            var foundFlaggedPetition: PFObject? = nil
            
            for flaggedPetition in flaggedPetitions {
                if let petition = flaggedPetition["petition"] as? PFObject {
                    if petition.objectId == dappId {
                        foundFlaggedPetition = flaggedPetition
                    }
                }
            }
            
            if let foundFlaggedPetition = foundFlaggedPetition {
                foundFlaggedPetition.deleteInBackgroundWithBlock({
                    (success: Bool, error: NSError?) in
                    completion(error: error)
                })
            } else {
                completion(error: nil)
            }
        }
    }
}
