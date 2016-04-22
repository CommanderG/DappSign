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
        self.initMapWebViewWithMapURLString(nil)
        self.initMajoritySupportDistrictsCountLabelWithDistrictsCount(nil)
        self.initTopDistrictLabelWithDapp(dapp)
        self.initSecondTopDistrictLabelWithDapp(dapp)
        self.initThirdTopDistrictLabelWithDapp(dapp)
        self.initUserDistrictRankLabelWithDapp(dapp)
        self.initTotalDistrictsCountLabelWithDapp(dapp)
        self.percentsVC?.showPercents(0)
        
        if let dapp = dapp {
            DappMappHelper.dappMappInfoForDapp(dapp) {
                (dappMappInfo: DappMappInfo?) -> Void in
                self.initMapWebViewWithMapURLString(dappMappInfo?.mapURLString)
                self.initMajoritySupportDistrictsCountLabelWithDistrictsCount(
                    dappMappInfo?.districtsWithMajoritySupportCount
                )
                
                if let percents = dappMappInfo?.percents {
                    self.percentsVC?.showPercents(percents)
                }
            }
        }
    }
    
    // MARK: - private
    
    private func initMapWebViewWithMapURLString(mapURLString: String?) {
        self.mapWebView.hidden = true
        
        var URLString: String? = nil
        
        if let mapURLString = mapURLString {
            URLString = mapURLString
        } else {
            URLString = SVGMapGenerator.generateEmptyMap()
        }
        
        if let URLString = URLString {
            self.mapWebView.hidden = false
            
            let URL = NSURL(fileURLWithPath: URLString)
            let request = NSURLRequest(URL: URL)
            
            self.mapWebView.loadRequest(request)
        }
    }
    
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
