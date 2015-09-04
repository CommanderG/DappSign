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
    @IBOutlet weak var label: UILabel!
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.webView.delegate = self
    }
    
    internal func showSVGMapAtURL(SVGMapURL: NSURL) {
        let request = NSURLRequest(URL: SVGMapURL)
        
        self.webView.loadRequest(request)
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
