//
//  FacebookHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class FacebookHelper {
    class func postActionToFacebook(image: UIImage, completion: (success: Bool, error: NSError?) -> Void) -> Void {
        
        self.performFacebookPublishAction({ () -> Void in
            
            let image = [[
                "url": image,
                "user_generated": "true",
                ]]
            
            // create og obj
            let path = "me/dappsign:create"
            let object = FBGraphObject.openGraphObjectForPostWithType("dappsign:dappsign", title: nil, image: image, url: "http://fb.me/1561473017435372", description: nil) as FBGraphObjectProtocol
            
            let bridge = FacebookBridge()
            let action = bridge.graphObject()
            action.setObject(object, forKey: "dappsign")
            
            FBOpenGraphActionParams(action: action, actionType: "dappsign:create", previewPropertyName: "dappsign")
            
            FBDialogs.presentShareDialogWithOpenGraphAction(action, actionType: "dappsign:create", previewPropertyName: "dappsign", handler: { ( call, results, error) -> Void in
                println(results)
                println(error)
            })
        }, failure: {
            (error) -> Void in
            completion(success: false, error: error)
        })
    }
    
    class func postImageToFacebook(image: UIImage, completion: (success: Bool, error: NSError?) -> Void) -> Void {
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
                var connection = FBRequestConnection()
                connection.errorBehavior = .ReconnectSession
                
                connection.addRequest(FBRequest(forUploadPhoto: image),
                    completionHandler: {
                        (innerConnection, result, error) -> Void in
                        if error == nil {
                            completion(success: true, error: nil)
                        } else {
                            completion(success: false, error: error)
                        }
                })
                connection.start()
            }, failure: {
                (error) -> Void in
                completion(success: false, error: error)
            })
        }
    }
    
    private class func performFacebookPublishAction(action: () -> Void, failure: (error: NSError?) -> Void) -> Void {
        let permissions = FBSession.activeSession().permissions as? [String]
        let publishActionsPermission = "publish_actions"
        
        if permissions != nil && contains(permissions!, publishActionsPermission) {
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
                    
                    println("Unable to get permission to post")
                }
        }
    }
}
