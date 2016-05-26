//
//  FacebookHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class FacebookHelper {
    class func postImageToFacebook(
        image: UIImage,
        dapp: PFObject,
        completion: (success: Bool, error: NSError?) -> Void
    ) -> Void {
        let photos = [ image ]
        let photoParams = FBPhotoParams(photos: photos)
        var shareDialogHasBeenPresented = false
        
        if FBDialogs.canPresentShareDialogWithPhotos() {
            let appCall = FBDialogs.presentShareDialogWithPhotoParams(photoParams, clientState: [:],
                handler: { (
                    appCall: FBAppCall?,
                    clientState: [NSObject: AnyObject]?,
                    error: NSError?
                ) -> Void in
                    if let error = error {
                        completion(success: false, error: error)
                        
                        return
                    }
            })
            
            if let _ = appCall {
                shareDialogHasBeenPresented = true
            }
        }
        
        if shareDialogHasBeenPresented {
            completion(success: false, error: nil)
            
            return
        }
        
        self.getHashtagsStringForDapp(dapp, completion: {
            (hashtagsString: String?, error: NSError?) -> Void in
            if let hashtagsString = hashtagsString {
                let message = self.getPostMessageWithHashtagsString(hashtagsString, dapp: dapp)
                
                self.requestPublishPermission {
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.makePostWithMessage(message, picture: image, completion: completion)
                    } else {
                        completion(success: false, error: error)
                    }
                }
            } else {
                completion(success: false, error: error)
            }
        })
    }
    
    private class func makePostWithMessage(message: String,
        picture: UIImage,
        completion: (success: Bool, error: NSError?) -> Void
    ) {
        let parameters = [
            "message": message,
            "picture": picture
        ]
        
        FBRequestConnection.startWithGraphPath("me/photos",
            parameters: parameters,
            HTTPMethod: "POST",
            completionHandler: {
                (connection: FBRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    completion(success: false, error: error)
                } else {
                    completion(success: true, error: error)
                }
        })
    }
    
    private class func getPostMessageWithHashtagsString(hashtagsString: String,
        dapp: PFObject
    ) -> String {
        var updatedHashtagsString = hashtagsString
        let dailyDappHashtag = "#DailyDapp"
        
        if hashtagsString.characters.count == 0 {
            updatedHashtagsString += dailyDappHashtag
        } else {
            updatedHashtagsString += " \(dailyDappHashtag)"
        }
        
        var message = "hashtagsString"
        
        if let dappSignID = dapp.objectId {
            message += "\nwww.dappsign.com\(dappSignID)"
        }
        
        return message
    }
    
    private class func getHashtagsStringForDapp(dapp: PFObject,
        completion: (hashtagsString: String?, error: NSError?) -> Void
    ) {
        let hashtagsRelation = dapp.relationForKey("hashtags")
        let query = hashtagsRelation.query()
        
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = objects as? [PFObject] {
                let hashtags = objects.map({
                    (object: PFObject) -> String? in
                    let hashtagName = object["name"] as? String
                    
                    return hashtagName
                }).map({
                    (hashtagName: String?) -> String in
                    return hashtagName!
                }).map({
                    (hashtagName: String) -> String in
                    return "#" + hashtagName
                })
                
                let hashtagsString = hashtags.joinWithSeparator(" ")
                
                completion(hashtagsString: hashtagsString, error: nil)
            } else {
                completion(hashtagsString: nil, error: error)
            }
        })
    }
    
    private class func requestPublishPermission(
        completion: (success: Bool, error: NSError?) -> Void
    ) {
        let activeSession = FBSession.activeSession()
        let publishActionsPermission = "publish_actions"
        let activeSessionHasPermissionPublishActionsPermission = self.activeSessionHasPermission(
            publishActionsPermission
        )
        
        if activeSessionHasPermissionPublishActionsPermission {
            completion(success: true, error: nil)
            
            return
        }
        
        let publishPermissions = [ publishActionsPermission ]
        
        activeSession.requestNewPublishPermissions(publishPermissions,
            defaultAudience: .Friends,
            completionHandler: {
                (session: FBSession?, error: NSError?) -> Void in
                if let error = error {
                    completion(success: false, error: error)
                } else {
                    completion(success: true, error: nil)
                }
        })
    }
    
    private class func activeSessionHasPermission(permission: String) -> Bool {
        let activeSession = FBSession.activeSession()
        
        if let permissions = activeSession.permissions as? [String] {
            let publishActionsPermission = "publish_actions"
            
            if permissions.contains(publishActionsPermission) {
                return true
            }
        }
        
        return false
    }
}
