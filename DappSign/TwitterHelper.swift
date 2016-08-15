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
    internal class func tweetDapp(
        dapp: PFObject,
        completion: (success: Bool, error: NSError?) -> Void
    ) -> Void {
        let twitter = Twitter.sharedInstance()
        
        twitter.logInWithCompletion {
            (session: TWTRSession?, error: NSError?) -> Void in
            guard let session = session else {
                completion(success: false, error: error)
                
                return
            }
            
            self.createAndUploadImage(dapp, session: session, completion: {
                (mediaID: String?, error: NSError?) -> Void in
                guard let mediaID = mediaID else {
                    completion(success: false, error: error)
                    
                    return
                }
                
                self.getStatusForDapp(dapp, completion: {
                    (status: String?, error: NSError?) -> Void in
                    guard let status = status else {
                        completion(success: false, error: error)
                        
                        return
                    }
                    
                    self.tweetImageWithUserID(session.userID,
                        mediaID: mediaID,
                        status: status,
                        completion: completion
                    )
                })
            })
        }
    }
    
    private class func createAndUploadImage(
        dapp: PFObject,
        session: TWTRSession,
        completion: (mediaID: String?, error: NSError?) -> Void
    ) {
        let socialVC = SocialVC.sharedInstance
        let image = socialVC?.renderWithDapp(dapp, forSocialNetwork: .Twitter)
        
        if let image = image {
            self.uploadImageToTwitterWithUserID(session.userID, image: image, completion: {
                (mediaID: String?, error: NSError?) -> Void in
                completion(mediaID: mediaID, error: error)
            })
        } else {
            completion(mediaID: nil, error: nil)
        }
    }
    
    private class func getStatusForDapp(dapp: PFObject,
        completion: (status: String?, error: NSError?) -> Void
    ) {
        DappsHelper.getHashtagsStringForDapp(dapp) {
            (hashtagsString: String?, error: NSError?) -> Void in
            if let hashtagsString = hashtagsString {
                var updatedHashtagsString = hashtagsString
                let dailyDappHashtag = "#DailyDapp"
                
                if hashtagsString.characters.count == 0 {
                    updatedHashtagsString += dailyDappHashtag
                } else {
                    updatedHashtagsString += " \(dailyDappHashtag)"
                }
                
                var status = updatedHashtagsString
                
                if let dappSignID = dapp.objectId {
                    status += " http://dappsign.com/?petition_id=\(dappSignID)"
                }
                
                completion(status: status, error: nil)
            } else {
                completion(status: nil, error: error)
            }
        }
    }
    
    private class func uploadImageToTwitterWithUserID(
        userID: String,
        image: UIImage,
        completion: (mediaID: String?, error: NSError?) -> Void
    ) -> Void {
        if let imageData = UIImagePNGRepresentation(image) {
            let parameters = ["media": imageData.base64EncodedStringWithOptions([])]
            let twitterAPIClient = TWTRAPIClient(userID: userID)
            
            var requestCreationError: NSError? = nil
            let uploadRequest = twitterAPIClient.URLRequestWithMethod("POST",
                URL: "https://upload.twitter.com/1.1/media/upload.json",
                parameters: parameters,
                error: &requestCreationError
            )
            
            if let error = requestCreationError {
                print(error)
                
                completion(mediaID: nil, error: error)
            } else {
                twitterAPIClient.sendTwitterRequest(uploadRequest, completion: {
                    (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    if let data = data {
                        do {
                            let responseJSON = try NSJSONSerialization.JSONObjectWithData(data,
                                options: .MutableContainers
                            )
                            let mediaID = responseJSON["media_id_string"] as? String
                            
                            completion(mediaID: mediaID, error: error)
                        } catch let error as NSError {
                            print(error)
                            
                            completion(mediaID: nil, error: error)
                        } catch {
                            completion(mediaID: nil, error: nil)
                        }
                    } else if let error = error {
                        print(error)
                        
                        completion(mediaID: nil, error: error)
                    } else {
                        print("Unknown error during sending Twitter request.")
                        
                        completion(mediaID: nil, error: error)
                    }
                })
            }
        }
    }
    
    private class func tweetImageWithUserID(
        userID: String,
        mediaID: String,
        status: String,
        completion: (success: Bool, error: NSError?) -> Void
    ) -> Void {
        let parameters = [
            "status":     status,
            "wrap_links": "true",
            "media_ids":  mediaID
        ]
        
        let twitterAPIClient = TWTRAPIClient(userID: userID)
        var requestCreationError: NSError? = nil
        
        let tweetRequest = twitterAPIClient.URLRequestWithMethod("POST",
            URL: "https://api.twitter.com/1.1/statuses/update.json",
            parameters: parameters,
            error: &requestCreationError
        )
        
        if let error = requestCreationError {
            print(error)
            
            completion(success: false, error: error)
        } else {
            twitterAPIClient.sendTwitterRequest(tweetRequest, completion: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    print(error)
                    
                    completion(success: false, error: error)
                } else {
                    completion(success: true, error: error)
                }
            })
        }
    }
}
