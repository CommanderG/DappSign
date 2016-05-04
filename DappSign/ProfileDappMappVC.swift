//
//  ProfileDappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ProfileDappMappVC: UIViewController {
    internal static let storyboardID = "profileDappMappVC"
    
    @IBOutlet weak var mapWebView:             UIWebView!
    @IBOutlet weak var majoritySupportLabel:   UILabel!
    @IBOutlet weak var topDistrictLabel:       UILabel!
    @IBOutlet weak var secondTopDistrictLabel: UILabel!
    @IBOutlet weak var thirdTopDistrictLabel:  UILabel!
    @IBOutlet weak var supportLabel:           UILabel!
    
    private var percentsVC: PercentsVC? = nil
    
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
        DappMappViewHelper.initMapWebView(self.mapWebView, mapURLString: nil)
        self.initMajoritySupportLabelWithDistrictsCount(0)
        self.percentsVC?.showPercents(0)
        DappMappViewHelper.initDistrictLabels(
            topDistrictLabel: self.topDistrictLabel,
            secondTopDistrictLabel: self.secondTopDistrictLabel,
            thirdTopDistrictLabel: self.thirdTopDistrictLabel,
            dappMappInfo: nil
        )
        
        if let dapp = dapp {
            DappMappHelper.dappMappInfoForDapp(dapp) {
                (dappMappInfo: DappMappInfo?) -> Void in
            }
        }
    }
    
    // MARK: - UI
    
    private func initMajoritySupportLabelWithDistrictsCount(districtsCount: Int) {
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case PercentsVC.embedSegueID:
                self.percentsVC = segue.destinationViewController as? PercentsVC
            case _:
                break
            }
        }
    }
}
