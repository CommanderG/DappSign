//
//  UserHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/7/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class UserHelper {
    typealias completionClosure = (success: Bool, errorMessage: String?) -> Void
    
    internal class func incrementDappScoreForUserWithID(
        userID: String,
        completion: completionClosure
    ) {
        Requests.userWithID(userID) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.incrementDappScoreForUser(user, completion: completion)
            } else if let error = error {
                let errorMessage =
                "Failed to download user with ID \(userID). Error: \(error.localizedDescription)"
                
                completion(success: false, errorMessage: errorMessage)
            } else {
                let errorMessage = "Failed to download user with ID \(userID). " +
                                   "Unknown error (this user may not exist in the database)."
                
                completion(success: false, errorMessage: errorMessage)
            }
        }
    }
    
    private class func incrementDappScoreForUser(user: PFUser, completion: completionClosure) {
        let dappScoreKey = "dappScore"
        
        if let dappScore = user[dappScoreKey] as? Int {
            let newDappScore = dappScore + 1
            
            user[dappScoreKey] = newDappScore
        } else {
            user[dappScoreKey] = 1
        }
        
        user.saveInBackgroundWithBlock({
            (success: Bool, error: NSError!) -> Void in
            if success {
                completion(success: success, errorMessage: nil)
            } else if let error = error {
                let errorMessage =
                "Failed to update dappScore for user with ID \(user.objectId). " +
                "Error: \(error.localizedDescription)"
                
                completion(success: success, errorMessage: errorMessage)
            } else {
                let errorMessage =
                "Failed to update dappScore for user with ID \(user.objectId). Unknown error."
                
                completion(success: success, errorMessage: errorMessage)
            }
        })
    }
    
    internal class func downloadAllUsersWithDistrict(district: String,
        completion: (users: [PFUser]?, error: NSError?) -> Void
    ) {
        let query = PFUser.query()
        
        query.whereKey("congressionalDistrictID", equalTo: district)
        
        ParseHelper.downloadAllObjectsWithQuery(query, downloadedObjects: []) {
            (objects: [PFObject]?, error: NSError?) -> Void in
            let users = objects as? [PFUser]
            
            completion(users: users, error: error)
        }
    }
}
