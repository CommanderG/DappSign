//
//  DappMappView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/1/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappMappView: XIBView {
    @IBOutlet weak var dappsCountLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var percentsView: PercentsView!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.webView.delegate = self
    }
    
    internal func show(dappsCount: UInt, SVGMapURLPath: String?, percents: UInt) {
        var str = "The DappSign has \(dappsCount) Dapp"
        
        if (dappsCount != 1) {
            str += "s"
        }
        
        self.dappsCountLabel.text = str
        self.webView.hidden = true
        
        if let mapURLPath = SVGMapURLPath {
            let URL = NSURL(fileURLWithPath: mapURLPath)
            let request = NSURLRequest(URL: URL)
            
            self.webView.loadRequest(request)
            self.webView.hidden = false
        }
        
        self.percentsView.showPercents(percents)
    }
}

extension DappMappView: UIWebViewDelegate {
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
