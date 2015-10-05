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
        }
        
        print("copyDappURL()")
    }
    
    @IBAction func copyDappEmbedCode() {
        if let embedCode = self.embedCodeTextView.text {
            UIPasteboard.generalPasteboard().string = embedCode
        }
        
        print("copyDappEmbedCode()")
    }
    
    @IBAction func hide() {
        self.hidden = true
        
        print("hide()")
    }
    
    // MARK: -
    
    internal func initURLAndEmbedCodeForDappWithID(dappID: String) {
        self.URLLabel.text = "http://www.dappsign.com/\(dappID)"
        self.embedCodeTextView.text = "<iframe width=\"260\" height=\"420\" src=\"http://www.dappsign.com/embed/\(dappID)\" frameborder=\"0\"></iframe>"
    }
}
