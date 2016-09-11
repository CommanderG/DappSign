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

class DappSignVC: UIViewController {
    @IBOutlet weak var dappStatementLabel : UILabel!
    @IBOutlet weak var dappSubmitterLabel : UILabel!
    @IBOutlet weak var dappScoreLabel     : UILabel!
    @IBOutlet weak var dailyDappLabel     : UILabel!
    
    internal static let embedSegueID: String = "embedDappSignVC"
    
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
