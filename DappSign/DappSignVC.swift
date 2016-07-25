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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DappSignViewsHelper.initViewLayer(self.view)
        DappSignViewsHelper.initFontsInDailyDappLabel(self.dailyDappLabel, fontSize: 12.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
