//
//  LinkView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/24/15.
//  Copyright © 2015 DappSign. All rights reserved.
//

import UIKit

protocol LinkViewDelegate {
    func closeLinkView()
}

class LinkView: XIBView {
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var webView: UIWebView!
    
    internal var delegate: LinkViewDelegate?
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        let borderColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).CGColor
        
        self.closeButton.layer.borderWidth = 1.0
        self.closeButton.layer.borderColor = borderColor
    }
    
    // MARK: - @IBActions
    
    @IBAction func close() {
        self.delegate?.closeLinkView()
    }
    
    // MARK: -
    
    internal func openURL(URL: NSURL) {
        if let blankPageURL = NSURL(string: "about:blank") {
            let blankPageRequest = NSURLRequest(URL: blankPageURL)
            
            self.webView.loadRequest(blankPageRequest)
        }
        
        let request = NSURLRequest(URL: URL)
        
        self.webView.loadRequest(request)
    }
}
