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
            if let img = socialVC.renderWithDapp(dapp) {
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
        
        self.getHashtagsStringForDapp(dapp, completion: {
            (hashtagsString: String?, error: NSError?) -> Void in
            if let hashtagsString = hashtagsString {
                self.getLinksForDapp(dapp, completion: {
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
        
        var message = updatedHashtagsString
        
        if let dappSignID = dapp.objectId {
            message += "\nwww.dappsign.com/\(dappSignID)"
        }
        
        if linkURLStrs.count > 0 {
            message += "\n\n"
            
            for linkIndex in 0 ..< linkURLStrs.count {
                let linkURLStr = linkURLStrs[linkIndex]
                
                message += "Link \(linkIndex + 1): \(linkURLStr)"
                
                if linkIndex < linkURLStrs.count - 1 {
                    message += "\n\n"
                }
            }
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
    
    private class func getLinksForDapp(dapp: PFObject,
        completion: (linkURLStrs: [String], error: NSError?) -> Void
    ) {
        Requests.downloadLinksForDapp(dapp, completion: {
            (linkObjs: [PFObject]?, error: NSError?) -> Void in
            if let linkObjs = linkObjs {
                let links = linkObjs.map({
                    (linkObj: PFObject) -> Link in
                    let link = Link(linkObj: linkObj)
                    
                    return link
                })
                
                let linkURLStrs = links.map({
                    (link: Link) -> String? in
                    return link.URLStr
                }).filter({
                    (linkURLStr: String?) -> Bool in
                    if let _ = linkURLStr {
                        return true
                    }
                    
                    return false
                }).map({
                    (linkURLStr: String?) -> String in
                    return linkURLStr!
                })
                
                completion(linkURLStrs: linkURLStrs, error: nil)
            } else {
                completion(linkURLStrs: [], error: nil)
            }
        })
    }
}
