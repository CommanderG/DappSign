//
//  Requests.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/19/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class Requests {
    class func uploadHashtags(hashtagNames: [String], completion: (hashtags: [PFObject]?, error: NSError!) -> Void) {
        let lowercaseHashtagNames = hashtagNames.map({ $0.lowercaseString })
        let hashtagsQuery = PFQuery(className: "DappHashtag")
        
        hashtagsQuery.whereKey("lowercaseName", containedIn: lowercaseHashtagNames)
        hashtagsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                completion(hashtags: nil, error: error)
                
                return
            }
            
            var hashtagsOnTheServer = objects as [PFObject]
            
            let hashtagsOnTheServerLowercaseNames = hashtagsOnTheServer.filter({
                $0["lowercaseName"] != nil
            }).map({
                $0["lowercaseName"]! as String
            })
            
            var hashtagNamesForUploading = hashtagNames.filter({
                !contains(hashtagsOnTheServerLowercaseNames, $0.lowercaseString)
            })
            
            if hashtagNamesForUploading.count > 0 {
                self.uploadHashtags(hashtagNamesForUploading, successfullyUploadedHashtag: {
                    (hashtag: PFObject) -> Void in
                    hashtagsOnTheServer.append(hashtag)
                }, finishedUploadingHashtags: {
                    () -> Void in
                    completion(hashtags: hashtagsOnTheServer, error: nil)
                })
            } else {
                completion(hashtags: hashtagsOnTheServer, error: nil)
            }
        }
    }
    
    class func downloadHashtagsWithNameWhichContains(nameSubstring: String, completion: (hashtags: [PFObject], error: NSError!) -> Void) {
        let hashtagsQuery = PFQuery(className: "DappHashtag")
        hashtagsQuery.limit = 1000
        
        hashtagsQuery.whereKey("lowercaseName", containsString: nameSubstring.lowercaseString)
        
        hashtagsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(hashtags: objects as [PFObject], error: error)
        }
    }
    
    class func downloadDappsWithHashtag(hashtag: PFObject, completion: (dapps: [PFObject], error: NSError!) -> Void) {
        let dappsQuery = PFQuery(className: "Dapps")
        dappsQuery.limit = 1000
        
        dappsQuery.whereKey("hashtags", equalTo: hashtag)
        
        dappsQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(dapps: objects as [PFObject], error: error)
        })
    }
    
    class func downloadDappsWithStatementWhichContains(statementSubstring: String, notSwipedByUser user: PFUser, completion: (dapps: [PFObject], error: NSError!) -> Void) {
        var query = DappQueriesBuilder.queryForAllDappsNotSwipedByUser(user,
            dappStatementSubstring: statementSubstring
        )
        query?.limit = 1000
        
        query?.whereKey("lowercaseDappStatement", containsString: statementSubstring.lowercaseString)
        
        query?.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(dapps: objects as [PFObject], error: error)
        }
    }
    
    class func downloadUsersWithNameWhichContains(nameSubstring: String, completion: (users: [PFObject], error: NSError!) -> Void) {
        let usersQuery = PFUser.query()
        usersQuery.limit = 1000
        
        usersQuery.whereKey("lowercaseName", containsString: nameSubstring.lowercaseString)
        
        usersQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(users: objects as [PFObject], error: error)
        }
    }
    
    // MARK: -
    
    private class func downloadHashtagWthName(name: String, completion: (hashtag: PFObject?, error: NSError!) -> Void) {
        let hashtagQuery = PFQuery(className: "DappHashtag")
        
        hashtagQuery.whereKey("lowercaseName", equalTo: name.lowercaseString)
        
        hashtagQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            let hashtags = objects as? [PFObject]
            let hashtag = hashtags?.first
            
            completion(hashtag: hashtag, error: error)
        }
    }
    
    private class func uploadHashtags(hashtagNames: [String], successfullyUploadedHashtag: (hashtag: PFObject) -> Void, finishedUploadingHashtags: () -> Void) {
        var hashtagsLeft = hashtagNames.count
        
        for hashtagName in hashtagNames {
            self.uploadHashtagWithName(hashtagName, completion: {
                (hashtag: PFObject?, error: NSError!) -> Void in
                --hashtagsLeft
                
                if error != nil {
                    println(error)
                } else {
                    if let hashtag = hashtag {
                        successfullyUploadedHashtag(hashtag: hashtag)
                    }
                }
                
                if hashtagsLeft == 0 {
                    finishedUploadingHashtags()
                }
            })
        }
    }
    
    private class func uploadHashtagWithName(hashtagName: String, completion: (hashtag: PFObject?, error: NSError!) -> Void) {
        var hashtag = PFObject(className: "DappHashtag")
        hashtag["name"] = hashtagName
        hashtag["lowercaseName"] = hashtagName.lowercaseString
        
        hashtag.saveInBackgroundWithBlock {
            (succeded: Bool, error: NSError!) -> Void in
            if error != nil {
                completion(hashtag: nil, error: error)
                
                return
            }
            
            completion(hashtag: hashtag, error: nil)
        }
    }
}
