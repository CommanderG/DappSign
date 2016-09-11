
//
//  BlockedUsersHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class BlockedUsersHelper: NSObject {
    private static let blockedUserClassName = "BlockedUser"
    
    internal class func addUserWithId(userId: String, completion: (success: Bool) -> Void) {
        self.blockedUsers {
            (users: [PFUser]?) in
            guard let blockedUsers = users else {
                completion(success: false)
                
                return
            }
            
            for blockedUser in blockedUsers {
                if blockedUser.objectId == userId {
                    completion(success: true)
                    
                    return
                }
            }
            
            let user = PFUser(outDataWithObjectId: userId)
            let blockedUser = PFObject(className: self.blockedUserClassName)
            
            blockedUser["user"] = user
            
            blockedUser.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) in
                if success {
                    completion(success: success)
                } else {
                    completion(success: false)
                    print(error)
                }
            }
        }
    }
    
    internal class func blockedUsers(completion: (users: [PFUser]?) -> Void) {
        let query = PFQuery(className: self.blockedUserClassName)
        
        query.limit = 1000
        
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            if let blockedUsers = objects as? [PFObject] {
                let users = blockedUsers.map({
                    (blockedUser: PFObject) -> PFUser? in
                    return blockedUser["user"] as? PFUser
                }).filter({
                    (user: PFUser?) -> Bool in
                    if let _ = user {
                        return true
                    }
                    
                    return false
                }).map({
                    (user: PFUser?) -> PFUser in
                    return user!
                })
                
                completion(users: users)
            } else {
                completion(users: nil)
                print(error)
            }
        }
    }
    
    internal class func blockedUsersCount(completion: (count: Int32) -> Void) {
        let query = PFQuery(className: self.blockedUserClassName)
        
        query.limit = 1000
        
        query.countObjectsInBackgroundWithBlock {
            (count: Int32, error: NSError?) in
            if let error = error {
                completion(count: count)
                print(error)
            } else {
                completion(count: count)
            }
        }
    }
}
