//
//  FacebookHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class FacebookHelper {
    internal class func shareDapp(
        dapp: PFObject,
        viewController: UIViewController,
        completion: (message: String?) -> Void
    ) {
        guard
            let socialVC = SocialVC.sharedInstance,
            let img = socialVC.renderWithDapp(dapp, forSocialNetwork: .Facebook) else {
                completion(message: "Failed to post the card. Failed to create petition image.")
                
                return
        }
        
        let canPresent = FBDialogs.canPresentOSIntegratedShareDialog()
        
        if !canPresent {
            completion(message: "Please log in on Facebook in Settings.")
            
            return
        }
        
        self.getMessage(dapp) {
            (message: String?) in
            guard let _ = message else {
                completion(message: "Failed to post the card. Failed to obtain post message.")
                
                return
            }
            
            FBDialogs.presentOSIntegratedShareDialogModallyFrom(
                viewController,
                initialText: message,
                image: img,
                url: nil,
                handler: {
                    (result: FBOSIntegratedShareDialogResult, error: NSError?) in
                    print(result, error)
                    
                    switch result {
                    case .Succeeded:
                        completion(message: "The card has been successfully posted.")
                        
                        break
                    case .Cancelled:
                        completion(message: nil)
                        
                        break
                    case .Error:
                        if let error = error {
                            completion(message: "Failed to post the card. Error: \(error)")
                        } else {
                            completion(message: "Failed to post the card. Unknown error.")
                        }
                        
                        break
                    }
                }
            )
        }
    }
    
    private class func getMessage(dapp: PFObject, completion: (message: String?) -> Void) -> Void {
        DappsHelper.getHashtagsStringForDapp(dapp, completion: {
            (hashtagsString: String?, error: NSError?) -> Void in
            guard let hashtagsString = hashtagsString else {
                completion(message: nil)
                
                return
            }
            
            DappsHelper.getLinksForDapp(dapp, completion: {
                (linkURLStrs: [String], error: NSError?) -> Void in
                let message = self.getPostMessageWithHashtagsString(hashtagsString,
                    dapp: dapp,
                    linkURLStrs: linkURLStrs
                )
                
                completion(message: message)
            })
        })
    }
    
    private class func getPostMessageWithHashtagsString(
        hashtagsString: String,
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
            message += "\n\nhttp://dappsign.com/?petition_id=\(dappSignID)"
        }
        
        if linkURLStrs.count > 0 {
            message += "\n\n" + DappsHelper.joinDappLinkURLStrings(linkURLStrs, separator: "\n\n")
        }
        
        return message
    }
}
