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
    
    @IBOutlet weak var districtsLabel: UILabel!
    @IBOutlet weak var webView:        UIWebView!
    @IBOutlet weak var percentsView:   PercentsView!
    
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
        self.showMapWithURL(emptySVGMapURLString)
        self.percentsView.showPercents(0)
        
        DappMappHelper.dappMappInfoForDapp(dapp) {
            (dappMappInfo: DappMappInfo?) -> Void in
            if let dappMappInfo = dappMappInfo {
                self.initDistrictsLabelTextWithDistricsOnTheMapCount(dappMappInfo.IDsFreqs.count)
                self.showMapWithURL(dappMappInfo.mapURLString)
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
    
    private func showMapWithURL(SVGMapURLPath: String?) {
        self.webView.hidden = true
        
        if let mapURLPath = SVGMapURLPath {
            let URL = NSURL(fileURLWithPath: mapURLPath)
            let request = NSURLRequest(URL: URL)
            
            self.webView.loadRequest(request)
            self.webView.hidden = false
        }
    }
}

extension DappMappVC: UIWebViewDelegate {
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
