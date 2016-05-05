//
//  ProfileDappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ProfileDappMappVC: UIViewController {
    @IBOutlet weak var mapWebView:             UIWebView!
    @IBOutlet weak var majoritySupportLabel:   UILabel!
    @IBOutlet weak var topDistrictLabel:       UILabel!
    @IBOutlet weak var secondTopDistrictLabel: UILabel!
    @IBOutlet weak var thirdTopDistrictLabel:  UILabel!
    @IBOutlet weak var supportLabel:           UILabel!
    
    private var percentsVC: PercentsVC? = nil
    private var dappMappInfo: DappMappInfo? = nil
    
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
        self.initUIWithDappMappInfo(self.dappMappInfo)
        
        if self.dappMappInfo != nil {
            return
        }
        
        if let dapp = dapp {
            DappMappHelper.dappMappInfoForDapp(dapp) {
                (dappMappInfo: DappMappInfo?) -> Void in
                self.dappMappInfo = dappMappInfo
                
                self.initUIWithDappMappInfo(self.dappMappInfo)
            }
        }
    }
    
    // MARK: - UI
    
    private func initUIWithDappMappInfo(dappMappInfo: DappMappInfo?) {
        DappMappViewHelper.initMapWebView(self.mapWebView,
            mapURLString: dappMappInfo?.mapURLString
        )
        
        if let districtsWithMajoritySupportCount = dappMappInfo?.districtsWithMajoritySupportCount {
            self.initMajoritySupportLabelWithDistrictsCount(districtsWithMajoritySupportCount)
        } else {
            self.initMajoritySupportLabelWithDistrictsCount(0)
        }
        
        DappMappViewHelper.initDistrictLabels(
            topDistrictLabel: self.topDistrictLabel,
            secondTopDistrictLabel: self.secondTopDistrictLabel,
            thirdTopDistrictLabel: self.thirdTopDistrictLabel,
            dappMappInfo: dappMappInfo
        )
        
        if let percents = dappMappInfo?.percents {
            self.percentsVC?.showPercents(percents)
        } else {
            self.percentsVC?.showPercents(0)
        }
        
        if let rank = dappMappInfo?.userDistrictRank {
            self.initSupportLabelWithRank(rank)
        } else {
            self.initSupportLabelWithRank(0)
        }
    }
    
    private func initMajoritySupportLabelWithDistrictsCount(districtsCount: Int) {
        let districtsCountString = NSMutableAttributedString(string: "\(districtsCount) districts")
        
        if let fontAvenirHeavy = UIFont(name: "Avenir-Heavy", size: 12.0) {
            districtsCountString.addAttribute(NSFontAttributeName,
                value: fontAvenirHeavy,
                range: NSMakeRange(0, districtsCountString.string.characters.count)
            )
        }
        
        let attributedText = NSMutableAttributedString(string: "Majority support in ")
        
        attributedText.appendAttributedString(districtsCountString)
        
        self.majoritySupportLabel.attributedText = attributedText
    }
    
    private func initSupportLabelWithRank(rank: Int) {
        self.supportLabel.text = "Support in your district. Rank \(rank)"
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

extension ProfileDappMappVC: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        DappMappViewHelper.handleWebViewDidFinishLoad(webView)
    }
}
