//
//  DappMappView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/1/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappMappView: UIView {
    @IBOutlet weak var dappsCountLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var percentsView: PercentsView!
    @IBOutlet weak var label: UILabel!
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        if let view = NSBundle.mainBundle().loadNibNamed("DappMappView", owner: self, options: nil).first as? UIView {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addSubview(view)
            
            // set width
            self.addConstraint(
                NSLayoutConstraint(
                    item:       view
                ,   attribute:  NSLayoutAttribute.Width
                ,   relatedBy:  NSLayoutRelation.Equal
                ,   toItem:     self
                ,   attribute:  NSLayoutAttribute.Width
                ,   multiplier: 1.0
                ,   constant:   0.0
                )
            )
            
            // set height
            self.addConstraint(
                NSLayoutConstraint(
                    item:       view
                ,   attribute:  NSLayoutAttribute.Height
                ,   relatedBy:  NSLayoutRelation.Equal
                ,   toItem:     self
                ,   attribute:  NSLayoutAttribute.Height
                ,   multiplier: 1.0
                ,   constant:   0.0
                )
            )
            
            // center horizontally
            self.addConstraint(
                NSLayoutConstraint(
                    item:       view
                ,   attribute:  NSLayoutAttribute.CenterX
                ,   relatedBy:  NSLayoutRelation.Equal
                ,   toItem:     self
                ,   attribute:  NSLayoutAttribute.CenterX
                ,   multiplier: 1.0
                ,   constant:   0.0
                )
            )
            
            // center vertically
            self.addConstraint(
                NSLayoutConstraint(
                    item:       view
                ,   attribute:  NSLayoutAttribute.CenterY
                ,   relatedBy:  NSLayoutRelation.Equal
                ,   toItem:     self
                ,   attribute:  NSLayoutAttribute.CenterY
                ,   multiplier: 1.0
                ,   constant:   0.0
                )
            )
            
            self.webView.delegate = self
            
            let mapURLStr = SVGMapGenerator.generate(["CA-01": 10, "NY-10": 25, "TX-03": 18])
            
            if let mapURLStr_ = mapURLStr, URL = NSURL(fileURLWithPath: mapURLStr_) {
                let request = NSURLRequest(URL: URL)
                
                self.webView.loadRequest(request)
            }
        }
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
