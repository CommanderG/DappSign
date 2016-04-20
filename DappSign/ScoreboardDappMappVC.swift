//
//  ScoreboardDappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ScoreboardDappMappVC: UIViewController {
    @IBOutlet weak var mapWebView:                         UIWebView!
    @IBOutlet weak var majoritySupportDistrictsCountLabel: UILabel!
    @IBOutlet weak var topDistrictLabel:                   UILabel!
    @IBOutlet weak var secondTopDistrictLabel:             UILabel!
    @IBOutlet weak var thirdTopDistrictLabel:              UILabel!
    @IBOutlet weak var userDistrictRankLabel:              UILabel!
    @IBOutlet weak var totalDistrictsCountLabel:           UILabel!
    
    internal static let embedSegueID = "embedScoreboardDappMappVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.showDappMappDataForDapp(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - internal
    
    internal func showDappMappDataForDapp(dapp: PFObject?) {
        self.initMapWebViewWithDapp(dapp)
        self.initMajoritySupportDistrictsCountLabelWithDapp(dapp)
        self.initTopDistrictLabelWithDapp(dapp)
        self.initSecondTopDistrictLabelWithDapp(dapp)
        self.initThirdTopDistrictLabelWithDapp(dapp)
        self.initUserDistrictRankLabelWithDapp(dapp)
        self.initTotalDistrictsCountLabelWithDapp(dapp)
    }
    
    // MARK: - private
    
    private func initMapWebViewWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initMajoritySupportDistrictsCountLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initTopDistrictLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initSecondTopDistrictLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initThirdTopDistrictLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initUserDistrictRankLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
    
    private func initTotalDistrictsCountLabelWithDapp(dapp: PFObject?) {
        if let dapp = dapp {
            
        } else {
            
        }
    }
}
