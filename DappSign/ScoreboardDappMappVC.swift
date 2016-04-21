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
            self.showInformationAboutDapp(dapp)
        } else {
            self.showMapWithURL(nil)
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
    
    // MARK: - map
    
    internal func showInformationAboutDapp(dapp: PFObject) {
        let emptyMapURLString = SVGMapGenerator.generateEmptyMap()
        
        self.showMapWithURL(emptyMapURLString)
        self.percentsVC?.showPercents(0)
        
        DappMappHelper.dappMappInfoForDapp(dapp) {
            (dappMappInfo: DappMappInfo?) -> Void in
            if let dappMappInfo = dappMappInfo {
                self.showMapWithURL(dappMappInfo.mapURLString)
                self.percentsVC?.showPercents(dappMappInfo.percents)
            }
        }
    }
    
    private func showMapWithURL(SVGMapURLPath: String?) {
        self.mapWebView.hidden = true
        
        if let mapURLPath = SVGMapURLPath {
            let URL = NSURL(fileURLWithPath: mapURLPath)
            let request = NSURLRequest(URL: URL)
            
            self.mapWebView.loadRequest(request)
            self.mapWebView.hidden = false
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
        let scaleX = CGRectGetWidth(webView.bounds) / webView.scrollView.contentSize.width
        let scaleY = CGRectGetHeight(webView.bounds) / webView.scrollView.contentSize.height
        let scale = max(scaleX, scaleY)
        
        webView.scrollView.minimumZoomScale = scale
        webView.scrollView.maximumZoomScale = scale
        webView.scrollView.zoomScale = scale
        webView.scrollView.scrollEnabled = false
    }
}
