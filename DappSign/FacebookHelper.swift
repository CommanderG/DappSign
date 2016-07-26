//
//  FacebookHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class FacebookHelper {
    internal class func shareDapp(dapp: PFObject, completion: (message: String) -> Void) {
        if let socialVC = SocialVC.sharedInstance {
            if let img = socialVC.renderWithDapp(dapp, forSocialNetwork: .Facebook) {
                self.postImageToFacebook(img, dapp: dapp, completion: {
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        completion(message: "The card has been successfully posted.")
                    } else if let error = error {
                        completion(message: "Failed to post the card. Error: \(error)")
                    } else {
                        completion(message: "Failed to post the card. Unknown error.")
                    }
                })
            }
        }
    }
    
    private class func postImageToFacebook(
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
        
        DappsHelper.getHashtagsStringForDapp(dapp, completion: {
            (hashtagsString: String?, error: NSError?) -> Void in
            if let hashtagsString = hashtagsString {
                DappsHelper.getLinksForDapp(dapp, completion: {
                    (linkURLStrs: [String], error: NSError?) -> Void in
                    
                    let message = self.getPostMessageWithHashtagsString(hashtagsString,
                        dapp: dapp,
                        linkURLStrs: linkURLStrs
                    )
                    
                    self.requestPublishPermission {
                        (success: Bool, error: NSError?) -> Void in
                        if success {
                            self.makePostWithMessage(message,
                                picture: image,
                                completion: completion
                            )
                        } else {
                            completion(success: false, error: error)
                        }
                    }
                })
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
        dapp: PFObject,
        linkURLStrs: [String]
    ) -> String {
        var updatedHashtagsString = hashtagsString
        let dailyDappHashtag = "#DailyDapp"
        
        if hashtagsString.characters.count == 0 {
            updatedHashtagsString += dailyDappHashtag
        } else {
            updatedHashtagsString += " \(dailyDappHashtag)"
        }
        
        var message = "A petition to your rep in the House:\n\n\(updatedHashtagsString)"
        
        if let dappSignID = dapp.objectId {
            message += "\n\nwww.dappsign.com/\(dappSignID)"
        }
        
        if linkURLStrs.count > 0 {
            message += "\n\n" + DappsHelper.joinDappLinkURLStrings(linkURLStrs, separator: "\n\n")
        }
        
        return message
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
