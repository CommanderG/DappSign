//
//  TwitterHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterHelper {
    class func tweetDapp(dapp: PFObject, image: UIImage, completion: (success: Bool, error: NSError?) -> Void) -> Void {
        Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if (session == nil) {
                println("Failed to sign in")
                
                completion(success: false, error: error)
            }
            
            println("Signed in Twitter as \(session.userName)")
            
            self.uploadImageToTwitter(image, completion: {
                (mediaID) -> Void in
                if let _mediaID = mediaID {
                    let hashtagsRelation = dapp.relationForKey("hashtags")
                    
                    hashtagsRelation.query().findObjectsInBackgroundWithBlock({
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        var status = ""
                        
                        if objects != nil {
                            let hashtags = objects as [PFObject]
                            let hashtagNames = hashtags.filter({
                                $0["name"] != nil
                            }).map({
                                $0["name"] as String!
                            }).map({
                                "#" + $0
                            })
                            
                            status = (hashtagNames as NSArray).componentsJoinedByString(" ")
                        }
                        
                        self.tweetImageWithMediaID(_mediaID, status: status, completion: {
                            (success: Bool) -> Void in
                            if success {
                                completion(success: true, error: nil)
                            } else {
                                completion(success: false, error: nil)
                            }
                        })
                    })
                } else {
                    let errorUserInfo = [NSLocalizedDescriptionKey: "Failed to upload image of the card to Twitter"]
                    let error = NSError(domain: "Twitter image upload", code: 0, userInfo: errorUserInfo)
                    
                    completion(success: false, error: error)
                }
            })
        }
    }
    
    private class func uploadImageToTwitter(image: UIImage, completion: (mediaID: String?) -> Void) -> Void {
        var requestCreationError: NSError?
        let imageData = UIImagePNGRepresentation(image)
        let parameters = ["media": imageData.base64EncodedStringWithOptions(nil)]
        let twitterAPIClient = Twitter.sharedInstance().APIClient
        
        let uploadRequest = twitterAPIClient.URLRequestWithMethod("POST",
            URL: "https://upload.twitter.com/1.1/media/upload.json",
            parameters: parameters,
            error: &requestCreationError
        )
        
        if uploadRequest == nil {
            println(requestCreationError)
            
            completion(mediaID: nil)
            
            return
        }
        
        twitterAPIClient.sendTwitterRequest(uploadRequest) {
            (response, data, connectionError) -> Void in
            if (connectionError != nil) {
                println(connectionError)
                
                completion(mediaID: nil)
                
                return
            }
            
            var JSONSerializationError : NSError?
            let responseJSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: nil,
                error: &JSONSerializationError
            )
            
            if JSONSerializationError != nil {
                println(JSONSerializationError)
                
                completion(mediaID: nil)
                
                return
            }
            
            let mediaID = responseJSON?["media_id_string"] as? String
            
            completion(mediaID: mediaID)
        }
    }
    
    private class func tweetImageWithMediaID(mediaID: String, status: String, completion: (success: Bool) -> Void) -> Void {
        let parameters = [
            "status": status,
            "wrap_links": "true",
            "media_ids": mediaID
        ]
        
        let twitterAPIClient = Twitter.sharedInstance().APIClient
        var requestCreationError: NSError?
        
        let tweetRequest = twitterAPIClient.URLRequestWithMethod("POST",
            URL: "https://api.twitter.com/1.1/statuses/update.json",
            parameters: parameters,
            error: &requestCreationError
        )
        
        if tweetRequest == nil {
            println(requestCreationError)
            
            completion(success: false)
            
            return
        }
        
        twitterAPIClient.sendTwitterRequest(tweetRequest, completion: {
            (response, data, connectionError) -> Void in
            if connectionError != nil {
                println(connectionError)
                
                completion(success: false)
                
                return
            }
            
            completion(success: true)
        })
    }
}
