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
    
    @IBOutlet var arrowImageViewsAndLabels: [UIView]!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.dappSignView = self.viewInXIB
    }
    
    // MARK: -
    
    func showDapp(dapp: PFObject?) {
        let dappFonts = DappFonts()
        
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
            
            if let
                dappFontName = dapp_["dappFont"] as? String,
                fontName = FontName(rawValue: dappFontName) {
                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                    let screenWidth = screenSize.width
                    let screenHeight = screenSize.height
                    let fontFileName = DappFonts.fontFileNameWithName(fontName)
                    
                    self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
                    
                    if screenWidth == 320.0 && screenHeight == 480.0 {
                        self.dappStatementLabel.font = UIFont(name: dappFontName, size: 22.0)
                    } else if screenWidth == 320.0 && screenHeight == 568.0 {
                        self.dappStatementLabel.font = UIFont(name: dappFontName, size: 27.0)
                    }
            }
            
            self.dappStatementLabel.textColor = UIColor.whiteColor()
            
            if let
                dappBgColoName = dapp_["dappBackgroundColor"] as? String,
                colorName = ColorName(rawValue: dappBgColoName) {
                    self.dappStatementLabel.backgroundColor =
                        DappColors.colorWithColorName(colorName)
            }
            
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
            
            self.showArrowImageViewsAndLabels()
        } else {
            self.dappsSwipesCountLabel.text = nil
            
            self.dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            self.dappStatementLabel.textColor = UIColor.whiteColor()
            self.dappStatementLabel.backgroundColor = DappColors.colorWithColorName(.MidnightBlue)
            
            let fontFileName = DappFonts.fontFileNameWithName(.Exo)
            
            self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
            
            self.usernameLabel.text = nil
            
            self.userProfileImageView.image = nil
            
            self.hideArrowImageViewsAndLabels()
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
    
    private func showArrowImageViewsAndLabels() {
        for view in self.arrowImageViewsAndLabels {
            view.hidden = false
        }
    }
    
    private func hideArrowImageViewsAndLabels() {
        for view in self.arrowImageViewsAndLabels {
            view.hidden = true
        }
    }
}
