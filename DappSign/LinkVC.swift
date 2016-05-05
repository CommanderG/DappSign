//
//  LinkVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class LinkVC: UIViewController {
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).CGColor
        
        self.closeButton.layer.borderWidth = 1.0
        self.closeButton.layer.borderColor = borderColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBActions
    
    @IBAction func close() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
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
