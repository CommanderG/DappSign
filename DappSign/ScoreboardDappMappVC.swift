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
    
    private var percentsVC: PercentsVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.showDappMappDataForDapp(nil)
        self.percentsVC?.showPercents(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - internal
    
    internal func showDappMappDataForDapp(dapp: PFObject?) {
        DappMappViewHelper.initMapWebView(self.mapWebView, mapURLString: nil)
        self.initMajoritySupportDistrictsCountLabelWithDistrictsCount(nil)
        DappMappViewHelper.initDistrictLabels(
            topDistrictLabel: self.topDistrictLabel,
            secondTopDistrictLabel: self.secondTopDistrictLabel,
            thirdTopDistrictLabel: self.thirdTopDistrictLabel,
            dappMappInfo: nil
        )
        self.initUserDistrictRankLabelWithRank(nil)
        self.initTotalDistrictsCountLabelWithDistrictsCount(nil)
        self.percentsVC?.showPercents(0)
        
        if let dapp = dapp {
            DappMappHelper.dappMappInfoForDapp(dapp) {
                (dappMappInfo: DappMappInfo?) -> Void in
                DappMappViewHelper.initMapWebView(self.mapWebView,
                    mapURLString: dappMappInfo?.mapURLString
                )
                self.initMajoritySupportDistrictsCountLabelWithDistrictsCount(
                    dappMappInfo?.districtsWithMajoritySupportCount
                )
                DappMappViewHelper.initDistrictLabels(
                    topDistrictLabel: self.topDistrictLabel,
                    secondTopDistrictLabel: self.secondTopDistrictLabel,
                    thirdTopDistrictLabel: self.thirdTopDistrictLabel,
                    dappMappInfo: dappMappInfo
                )
                self.initUserDistrictRankLabelWithRank(dappMappInfo?.userDistrictRank)
                self.initTotalDistrictsCountLabelWithDistrictsCount(
                    dappMappInfo?.districtsTotalCount
                )
                
                if let percents = dappMappInfo?.percents {
                    self.percentsVC?.showPercents(percents)
                }
            }
        }
    }
    
    // MARK: - private
    
    private func initMajoritySupportDistrictsCountLabelWithDistrictsCount(districtsCount: Int?) {
        if let districtsCount = districtsCount {
            if districtsCount == 1 {
                self.majoritySupportDistrictsCountLabel.text = "\(districtsCount) district."
            } else {
                self.majoritySupportDistrictsCountLabel.text = "\(districtsCount) districts."
            }
        } else {
            self.majoritySupportDistrictsCountLabel.text = "0 districts"
        }
    }
    
    private func initUserDistrictRankLabelWithRank(rank: Int?) {
        if let rank = rank {
            self.userDistrictRankLabel.text = "\(rank)"
        } else {
            self.userDistrictRankLabel.text = "0"
        }
    }
    
    private func initTotalDistrictsCountLabelWithDistrictsCount(districtCount: Int?) {
        if let districtCount = districtCount {
            self.totalDistrictsCountLabel.text = "\(districtCount)"
        } else {
            self.totalDistrictsCountLabel.text = "0"
        }
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

extension ScoreboardDappMappVC: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        DappMappViewHelper.handleWebViewDidFinishLoad(webView)
    }
}
