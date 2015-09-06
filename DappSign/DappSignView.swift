//
//  DappView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/1/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappSignView: XIBView {
    private var dappSignView: UIView? = nil
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var dappsSwipesCountLabel: UILabel!
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.dappSignView = self.viewInXIB
    }
    
    // MARK: -
    
    func showDapp(dapp: PFObject?) {
        let dappFonts = DappFonts()
        let dappColors = DappColors()
        
        if let dapp_ = dapp {
            if let dappScore = dapp_["dappScore"] as? Int {
                var text: String
                
                if dappScore == 1 {
                    text = "1 Dapp"
                } else {
                    text = "\(dappScore) Dapp"
                }
                
                self.dappsSwipesCountLabel.text = text
            } else {
                self.dappsSwipesCountLabel.text = nil
            }
            
            self.dappStatementLabel.text = dapp_["dappStatement"] as? String
            
            if let dappFontName = dapp_["dappFont"] as? String {
                let screenSize: CGRect = UIScreen.mainScreen().bounds
                let screenWidth = screenSize.width
                let screenHeight = screenSize.height
                self.dappStatementLabel.font = dappFonts.dappFontBook[dappFontName]
                
                if screenWidth == 320 && screenHeight == 480 {
                    self.dappStatementLabel.font = UIFont(name: dappFontName, size: 22)
                } else if screenWidth == 320 && screenHeight == 568 {
                    self.dappStatementLabel.font = UIFont(name: dappFontName, size: 27)
                }
            }
            
            self.dappStatementLabel.textColor = UIColor.whiteColor()
            
            if let dappBgColoName = dapp_["dappBackgroundColor"] as? String {
                self.dappStatementLabel.backgroundColor = dappColors.dappColorWheel[dappBgColoName]
            }
            
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
        } else {
            self.dappsSwipesCountLabel.text = nil
            self.dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            
            if let font = dappFonts.dappFontBook["exo"] {
                self.dappStatementLabel.font = font
            }
            
            self.dappStatementLabel.textColor = UIColor.whiteColor()
            self.dappStatementLabel.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
        }
        
        self.scoreView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.logoView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.dappSignView?.backgroundColor = self.dappStatementLabel.backgroundColor
    }
    
    func showUserInfo(user: PFObject?) {
        if let user_ = user {
            self.usernameLabel.text = user_["name"] as? String
            self.userProfileImageView.image = UIImage(data: user_["image"] as! NSData)
        } else {
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
        }
    }
}
