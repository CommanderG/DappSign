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
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var dappSubmitterLabel: UILabel!
    
    internal static let embedSegueID: String = "embedDappSignVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DappSignViewsHelper.initViewLayer(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - internal
    
    internal func showDappObject(dapp: PFObject?, lineSpacing: DappSignLineSpacing = .Default) {
        DappSignViewsHelper.showDappObject(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            view: self.view,
            lineSpacing: lineSpacing
        )
    }
    
    internal func showDapp(dapp: Dapp?) {
        DappSignViewsHelper.showDapp(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            view: self.view
        )
    }
}
