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
    
    internal class func initCurrentUserWithTheirFacebookProfileInformation(
        completion: Void -> Void
    ) {
        let user = PFUser.currentUser()
        
        if user == nil {
            completion()
            
            return
        }
        
        let FBSession = PFFacebookUtils.session()
        let accessToken = FBSession.accessTokenData.accessToken
        let URLString = "https://graph.facebook.com/me/picture?" +
                        "type=large"                             +
                        "&return_ssl_resources+1"                +
                        "&access_token=\(accessToken)"
        
        let url = NSURL(string: URLString)
        let urlRequest = NSURLRequest(URL: url!)
        let queue = NSOperationQueue.mainQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) {
            (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            user["image"] = data
            user["dappScore"] = 0
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    print("Successfully saved user's image and set user's dappScore to 0.")
                    
                    self.initCurrentUserNameWithTheirFacebookProfileName(completion)
                } else {
                    print(
                        "Failed to save user's image and set user's dappScore to 0. Error: \(error)"
                    )
                    
                    completion()
                }
            })
        }
    }
    
    internal class func addBlockedUserWithId(
        userId: String,
        completion: (error: NSError?) -> Void
    ) {
        guard let currentUser = PFUser.currentUser() else {
            return
        }
        
        let blockedUsersRelation = currentUser.relationForKey("blockedUsers")
        let user = PFUser(outDataWithObjectId: userId)
        
        blockedUsersRelation.addObject(user)
        currentUser.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            completion(error: error)
        }
    }
    
    // MARK: -
    
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
    
    private class func initCurrentUserNameWithTheirFacebookProfileName(completion: Void -> Void) {
        let user = PFUser.currentUser()
        
        if user == nil {
            completion()
            
            return
        }
        
        FBRequestConnection.startForMeWithCompletionHandler({
            connection, result, error in
            if let resultDict = result as? NSDictionary {
                let name = resultDict["name"] as! String
                
                user["name"] = name
                user["lowercaseName"] = name.lowercaseString
                
                user.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError!) -> Void in
                    if succeeded {
                        print("Successfully saved user's name.")
                    } else {
                        print("Failed to save user's name.")
                        print("Errro: \(error)")
                    }
                    
                    completion()
                })
            } else {
                completion()
            }
        })
    }
}
