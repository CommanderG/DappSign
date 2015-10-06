//
//  EmbedDappView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 10/1/15.
//  Copyright © 2015 DappSign. All rights reserved.
//

import UIKit

class EmbedDappView: XIBView {
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var embedCodeTextView: UITextView!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    // MARK: - IBAction
    
    @IBAction func copyDappURL() {
        if let URLStr = self.URLLabel.text {
            UIPasteboard.generalPasteboard().string = URLStr
            
            self.showCopiedToClipboardHUD()
        }
    }
    
    @IBAction func copyDappEmbedCode() {
        if let embedCode = self.embedCodeTextView.text {
            UIPasteboard.generalPasteboard().string = embedCode
            
            self.showCopiedToClipboardHUD()
        }
    }
    
    @IBAction func hide() {
        self.hidden = true
    }
    
    // MARK: -
    
    internal func initURLAndEmbedCodeForDappWithID(dappID: String) {
        self.URLLabel.text = "http://www.dappsign.com/\(dappID)"
        self.embedCodeTextView.text = "<iframe width=\"260\" height=\"420\" src=\"http://www.dappsign.com/embed/\(dappID)\" frameborder=\"0\"></iframe>"
    }
    
    // MARK: - 
    
    private func showCopiedToClipboardHUD() {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self, animated: true)
        progressHUD.mode = MBProgressHUDMode.Text
        progressHUD.labelText = "Copied to clipboard"
        
        delay(0.75) {
            progressHUD.hide(true)
        }
    }
}
