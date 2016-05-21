//
//  DappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappMappVC: UIViewController {
    internal static let storyboardID = "dappMappVC"
    
    @IBOutlet weak var districtsLabel:           UILabel!
    @IBOutlet weak var webView:                  UIWebView!
    @IBOutlet weak var percentsView:             PercentsView!
    @IBOutlet weak var topDistrictLabel:         UILabel!
    @IBOutlet weak var secondTopDistrictLabel:   UILabel!
    @IBOutlet weak var thirdTopDistrictLabel:    UILabel!
    @IBOutlet weak var districtRankLabel:        UILabel!
    @IBOutlet weak var totalDistrictsCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func showInformationAboutDapp(dapp: PFObject) {
        let emptySVGMapURLString = SVGMapGenerator.generateEmptyMap()
        
        self.initDistrictsLabelTextWithDistricsOnTheMapCount(0)
        DappMappViewHelper.initMapWebView(self.webView, mapURLString: emptySVGMapURLString)
        DappMappViewHelper.initDistrictLabels(
            topDistrictLabel: self.topDistrictLabel,
            secondTopDistrictLabel: self.secondTopDistrictLabel,
            thirdTopDistrictLabel: self.thirdTopDistrictLabel,
            dappMappInfo: nil
        )
        self.initRankLabels(nil)
        self.percentsView.showPercents(0)
        
        DappMappHelper.dappMappInfoForDapp(dapp) {
            (dappMappInfo: DappMappInfo?) -> Void in
            if let dappMappInfo = dappMappInfo {
                self.initDistrictsLabelTextWithDistricsOnTheMapCount(dappMappInfo.IDsFreqs.count)
                DappMappViewHelper.initMapWebView(self.webView,
                    mapURLString: dappMappInfo.mapURLString
                )
                DappMappViewHelper.initDistrictLabels(
                    topDistrictLabel: self.topDistrictLabel,
                    secondTopDistrictLabel: self.secondTopDistrictLabel,
                    thirdTopDistrictLabel: self.thirdTopDistrictLabel,
                    dappMappInfo: dappMappInfo
                )
                self.initRankLabels(dappMappInfo)
                self.percentsView.showPercents(dappMappInfo.percents)
            }
        }
    }
    
    // MARK: - private
    
    private func initDistrictsLabelTextWithDistricsOnTheMapCount(districtsOnTheMapCount: Int) {
        let totalDistrictsCount = SVGMapGenerator.districtsCount()
        
        self.districtsLabel.text = "\(districtsOnTheMapCount)/\(totalDistrictsCount) " +
                                   "Districts support this petition."
    }
    
    private func initRankLabels(dappMappInfo: DappMappInfo?) {
        if let rank = dappMappInfo?.userDistrictRank {
            self.districtRankLabel.text = "\(rank)"
        } else {
            self.districtRankLabel.text = "0"
        }
        
        let totalDistrictsCount = SVGMapGenerator.districtsCount()
        
        self.totalDistrictsCountLabel.text = "\(totalDistrictsCount)"
    }
}

extension DappMappVC: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        DappMappViewHelper.handleWebViewDidFinishLoad(webView)
    }
}
