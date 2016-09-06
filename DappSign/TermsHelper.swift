//
//  TermsHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/7/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class TermsHelper {
    private static let titleAgree     : String = "Agree"
    private static let titleDisagree  : String = "Disagree"
    private static let titleReadTerms : String = "Read Terms"
    private static let termsURLString : String = "https://dailydapp.com/dappsign-inc-terms-of-use-2b25ca2bb5fa#.440zyl7vs"
    
    internal class func userAgreedToTerms(user: PFUser) -> Bool {
        if let agreedToTerms = user["agreedToTerms"] as? Bool {
            return agreedToTerms
        }
        
        return false
    }
    
    internal class func showAlertViewWithDelegate(delegate: UIAlertViewDelegate?) {
        let alert = UIAlertView(
            title: "",
            message: "Please agree to our terms of service.",
            delegate: delegate,
            cancelButtonTitle: nil,
            otherButtonTitles: self.titleAgree, self.titleDisagree, self.titleReadTerms
        )
        
        alert.show()
    }
    
    internal class func handleAlertView(
        alertView: UIAlertView,
        clickedButtonAtIndex buttonIndex: Int,
        viewController: UIViewController,
        user: PFUser,
        completion: (agreed: Bool) -> Void
    ) {
        guard let buttonTitle = alertView.buttonTitleAtIndex(buttonIndex) else {
            return
        }
        
        switch buttonTitle {
        case self.titleAgree:
            user["agreedToTerms"] = true
            
            user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                completion(agreed: true)
            })
            
            break
        case self.titleDisagree:
            completion(agreed: false)
            break
        case self.titleReadTerms:
            guard let linkURL = NSURL(string: self.termsURLString) else {
                return
            }
            
            let linkVC = ViewControllerHelper.openLinkWithURL(
                linkURL,
                inViewController: viewController
            )
            
            linkVC?.didClose = {
                let delegate = alertView.delegate as? UIAlertViewDelegate ?? nil
                
                self.showAlertViewWithDelegate(delegate)
            }
            
            break
        default:
            break
        }
    }
}
