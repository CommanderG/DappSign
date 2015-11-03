//
//  FacebookHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class FacebookHelper {
    class func postImageToFacebook(image: UIImage, dapp: PFObject, completion: (success: Bool, error: NSError?) -> Void) -> Void {
        let photoParams = FBPhotoParams(photos: [image])
        var shareDialogHasBeenPresented = false
        
        if (FBDialogs.canPresentShareDialogWithPhotos()) {
            let appCall = FBDialogs.presentShareDialogWithPhotoParams(photoParams,
                clientState: nil,
                handler: {
                    (call, results, error) -> Void in
                    if error != nil {
                        completion(success: false, error: error)
                        
                        return
                    }
                }
            )
            
            if appCall != nil {
                shareDialogHasBeenPresented = true
            }
        }
        
        if !shareDialogHasBeenPresented {
            self.performFacebookPublishAction({
                () -> Void in
                let hashtagsRelation = dapp.relationForKey("hashtags")
                
                hashtagsRelation.query().findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    var message = ""
                    
                    if objects != nil {
                        let hashtags = objects as! [PFObject]
                        let hashtagNames = hashtags.filter({
                            $0["name"] != nil
                        }).map({
                            $0["name"] as! String
                        }).map({
                            "#" + $0
                        })
                        
                        message = (hashtagNames as NSArray).componentsJoinedByString(" ")
                    }
                    
                    message += "\nwww.dappsign.com";
                    
                    if let dappSignID = dapp.objectId {
                        message += "//" + dappSignID
                    }
                    
                    message += "\n#DappSign"
                    
                    let parameters = [
                        "message": message,
                        "picture": image
                    ]
                    
                    FBRequestConnection.startWithGraphPath("me/photos",
                        parameters: parameters,
                        HTTPMethod: "POST",
                        completionHandler: {
                            (connection:FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                            if error == nil {
                                completion(success: true, error: nil)
                            } else {
                                completion(success: false, error: error)
                            }
                    })
                })
            }, failure: {
                (error) -> Void in
                completion(success: false, error: error)
            })
        }
    }
    
    private class func performFacebookPublishAction(action: () -> Void, failure: (error: NSError?) -> Void) -> Void {
        let permissions = FBSession.activeSession().permissions as? [String]
        let publishActionsPermission = "publish_actions"
        
        if permissions != nil && (permissions!).contains(publishActionsPermission) {
            action()
            
            return
        }
        
        FBSession.activeSession().requestNewPublishPermissions([publishActionsPermission],
            defaultAudience: FBSessionDefaultAudience.Friends) {
                (session, error) -> Void in
                if error == nil {
                    action()
                } else {
                    failure(error: error)
                    
                    print("Unable to get permission to post")
                }
        }
    }
}
