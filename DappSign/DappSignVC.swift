//
//  DappSignVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

enum DappSignLineSpacing {
    case Default
    case SocialSharingImage
}

protocol DappSignVCDelegate {
    func didBlockUser()
}

class DappSignVC: UIViewController {
    @IBOutlet weak var dappStatementLabel : UILabel!
    @IBOutlet weak var dappSubmitterLabel : UILabel!
    @IBOutlet weak var dappScoreLabel     : UILabel!
    @IBOutlet weak var dailyDappLabel     : UILabel!
    
    internal static let embedSegueID: String = "embedDappSignVC"
    
    internal var delegate: DappSignVCDelegate? = nil
    
    private var dapp: PFObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DappSignViewsHelper.initViewLayer(self.view)
        DappSignViewsHelper.initFontsInDailyDappLabel(self.dailyDappLabel, fontSize: 12.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    
    @IBAction func flagPetition(sender: AnyObject?) {
        guard let dapp = self.dapp else {
            return
        }
        
        FlaggedPetitionsHelper.flagPetition(dapp) {
            (success: Bool) in
            var message = ""
            
            if success {
                message = "Successfully flagged petition."
            } else {
                message = "Failed to flag petition. Please try again later."
            }
            
            let alertView = UIAlertView(
                title: nil,
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK"
            )
            
            alertView.show()
        }
    }
    
    @IBAction func blockUser(sender: AnyObject?) {
        guard let dapp = self.dapp, userId = dapp["userid"] as? String else {
            return
        }
        
        if let currentUser = PFUser.currentUser() {
            if currentUser.objectId == userId {
                let alertView = UIAlertView(
                    title: nil,
                    message: "You can't block yourself",
                    delegate: nil,
                    cancelButtonTitle: "OK"
                )
                
                alertView.show()
                
                return
            }
        }
        
        BlockedUsersHelper.addUserWithId(userId) {
            (success: Bool) in
            if !success {
                let alertView = UIAlertView(
                    title: nil,
                    message: "Failed to block user. Please try again later.",
                    delegate: nil,
                    cancelButtonTitle: "OK"
                )
                
                alertView.show()
                
                return
            }
            
            UserHelper.addBlockedUserWithId(userId) {
                (success: Bool, error: NSError?) in
                if let error = error {
                    print(
                        "Failed to add user with ID \(userId) to blocked users. " +
                        "Error: \(error)"
                    )
                    
                    let alertView = UIAlertView(
                        title: nil,
                        message: "Failed to block user. Please try again later.",
                        delegate: nil,
                        cancelButtonTitle: "OK"
                    )
                    
                    alertView.show()
                } else {
                    let alertView = UIAlertView(
                        title: nil,
                        message: "Successfully blocked user.",
                        delegate: nil,
                        cancelButtonTitle: "OK"
                    )
                    
                    alertView.show()
                    
                    self.delegate?.didBlockUser()
                }
            }
        }
    }
    
    // MARK: - internal
    
    internal func showDappObject(dapp: PFObject?, lineSpacing: DappSignLineSpacing = .Default) {
        DappSignViewsHelper.showDappObject(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            dappScoreLabel: self.dappScoreLabel,
            view: self.view,
            lineSpacing: lineSpacing
        )
        
        self.dapp = dapp
    }
    
    internal func showDapp(dapp: Dapp?) {
        DappSignViewsHelper.showDapp(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            dappScoreLabel: self.dappScoreLabel,
            view: self.view
        )
    }
}
