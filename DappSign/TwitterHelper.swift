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
    class func tweetDapp(dapp: PFObject,
        image: UIImage,
        completion: (success: Bool, error: NSError?) -> Void
    ) -> Void {
        Twitter.sharedInstance().logInWithCompletion {
            (session: TWTRSession?, error: NSError?) -> Void in
            if let session = session {
                print("Signed in Twitter as \(session.userName)")
                
                self.uploadImageToTwitterWithUserID(session.userID, image: image, completion: {
                    (mediaID: String?) -> Void in
                    if let mediaID = mediaID {
                        let hashtagsRelation = dapp.relationForKey("hashtags")
                        
                        hashtagsRelation.query().findObjectsInBackgroundWithBlock({
                            (objects: [AnyObject]!, error: NSError!) -> Void in
                            var status = ""
                            
                            if objects != nil {
                                let hashtags = objects as! [PFObject]
                                let hashtagNames = hashtags.filter({
                                    $0["name"] != nil
                                }).map({
                                    $0["name"] as! String
                                }).map({
                                    "#" + $0
                                })
                                
                                status = (hashtagNames as NSArray).componentsJoinedByString(" ")
                            }
                            
                            status += "\nwww.dappsign.com";
                            
                            if let dappSignID = dapp.objectId {
                                status += "//" + dappSignID
                            }
                            
                            status += "\n#DappSign"
                            
                            self.tweetImageWithUserID(session.userID,
                                mediaID: mediaID,
                                status: status,
                                completion: {
                                    (success: Bool) -> Void in
                                    if success {
                                        completion(success: true, error: nil)
                                    } else {
                                        completion(success: false, error: nil)
                                    }
                            })
                        })
                    } else {
                        let errorUserInfo = [
                            NSLocalizedDescriptionKey:
                            "Failed to upload image of the card to Twitter"
                        ]
                        let error = NSError(
                            domain: "Twitter image upload",
                            code: 0,
                            userInfo: errorUserInfo
                        )
                        
                        completion(success: false, error: error)
                    }
                })
            } else {
                print("Failed to sign in")
                
                completion(success: false, error: error)
            }
        }
    }
    
    private class func uploadImageToTwitterWithUserID(
        userID: String,
        image: UIImage,
        completion: (mediaID: String?) -> Void
    ) -> Void {
        if let imageData = UIImagePNGRepresentation(image) {
            let parameters = ["media": imageData.base64EncodedStringWithOptions([])]
            let twitterAPIClient = TWTRAPIClient(userID: userID)
            
            var requestCreationError: NSError? = nil
            let uploadRequest = twitterAPIClient.URLRequestWithMethod("POST",
                URL:        "https://upload.twitter.com/1.1/media/upload.json",
                parameters: parameters,
                error:      &requestCreationError
            )
            
            if let error = requestCreationError {
                print(error)
                
                completion(mediaID: nil)
            } else {
                twitterAPIClient.sendTwitterRequest(uploadRequest, completion: {
                    (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    if let data = data {
                        do {
                            let responseJSON = try NSJSONSerialization.JSONObjectWithData(data,
                                options: .MutableContainers
                            )
                            let mediaID = responseJSON["media_id_string"] as? String
                            
                            completion(mediaID: mediaID)
                        } catch let error as NSError {
                            print(error)
                            
                            completion(mediaID: nil)
                        } catch {
                            completion(mediaID: nil)
                        }
                    } else if let error = error {
                        print(error)
                        
                        completion(mediaID: nil)
                    } else {
                        print("Unknown error during sending Twitter request.")
                        
                        completion(mediaID: nil)
                    }
                })
            }
        }
    }
    
    private class func tweetImageWithUserID(
        userID: String,
        mediaID: String,
        status: String,
        completion: (success: Bool) -> Void
    ) -> Void {
        let parameters = [
            "status":     status,
            "wrap_links": "true",
            "media_ids":  mediaID
        ]
        
        let twitterAPIClient = TWTRAPIClient(userID: userID)
        var requestCreationError: NSError? = nil
        
        let tweetRequest = twitterAPIClient.URLRequestWithMethod("POST",
            URL:        "https://api.twitter.com/1.1/statuses/update.json",
            parameters: parameters,
            error:      &requestCreationError
        )
        
        if let error = requestCreationError {
            print(error)
            
            completion(success: false)
        } else {
            twitterAPIClient.sendTwitterRequest(tweetRequest, completion: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error)
                    
                    completion(success: false)
                } else {
                    completion(success: true)
                }
            })
        }
    }
}
