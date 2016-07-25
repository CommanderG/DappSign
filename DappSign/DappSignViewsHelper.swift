//
//  DappSignViewsHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappSignViewsHelper {
    // MARK: - internal
    
    internal class func initViewLayer(view: UIView!) {
        view.layer.cornerRadius = 12.0
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2.0
    }
    
    internal class func showDappObject(dapp: PFObject?,
        dappStatementLabel: UILabel!,
        dappSubmitterLabel: UILabel!,
        dappScoreLabel: UILabel!,
        view: UIView!,
        lineSpacing: DappSignLineSpacing
    ) {
        var fontSize: CGFloat = 25.0
        
        guard let dapp = dapp else {
            dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            
            let fontFileName = DappFonts.fontFileNameWithName(.Exo)
            
            dappStatementLabel.font = UIFont(name: fontFileName, size: fontSize)
            
            return
        }
        
        let dappScore = dapp["dappScore"] as? Int
        
        self.initDappScoreLabel(dappScoreLabel, dappScore: dappScore)
        
        let defaultFont = UIFont.systemFontOfSize(fontSize)
        
        dappStatementLabel.font = defaultFont
        
        switch lineSpacing {
        case .Default:
            dappStatementLabel.text = dapp["dappStatement"] as? String
            
            if let fontName = DappHelper.getFontName(dapp) {
                let fontFileName = DappFonts.fontFileNameWithName(fontName)
                
                dappStatementLabel.font = UIFont(name: fontFileName, size: fontSize)
            }
            
            break
        case .SocialSharingImage:
            fontSize = 30.0
            
            if let dappStatement = dapp["dappStatement"] as? String {
                let paragraphStyle = NSMutableParagraphStyle()
                
                paragraphStyle.lineSpacing = 20.0
                paragraphStyle.alignment = .Center
                
                let attributedString = NSMutableAttributedString(string: dappStatement)
                let allStringRange = NSMakeRange(0, attributedString.length)
                
                attributedString.addAttribute(NSParagraphStyleAttributeName,
                    value: paragraphStyle,
                    range: allStringRange
                )
                
                if let fontName = DappHelper.getFontName(dapp) {
                    let fontFileName = DappFonts.fontFileNameWithName(fontName)
                    
                    if let font = UIFont(name: fontFileName, size: fontSize) {
                        attributedString.addAttribute(NSFontAttributeName,
                            value: font,
                            range: allStringRange
                        )
                    }
                }
                
                dappStatementLabel.attributedText = attributedString
            } else {
                dappStatementLabel.text = ""
            }
            
            break
        }
        
        if let colorName = DappHelper.getColorName(dapp) {
            dappStatementLabel.backgroundColor = DappColors.colorWithColorName(colorName)
        }
        
        view.backgroundColor = dappStatementLabel.backgroundColor
        
        self.initDappSubmitterLabelTextWithDapp(dapp, dappSubmitterLabel: dappSubmitterLabel)
    }
    
    internal class func showDapp(dapp: Dapp?,
        dappStatementLabel: UILabel!,
        dappSubmitterLabel: UILabel!,
        dappScoreLabel: UILabel!,
        view: UIView!
    ) {
        dappStatementLabel.text = dapp?.dappStatement ?? ""
        
        if let dappFontName = dapp?.dappFont, fontName = FontName(rawValue: dappFontName) {
            let fontFileName = DappFonts.fontFileNameWithName(fontName)
            
            dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
        }
        
        if let
            dappBgColoName = dapp?.dappBackgroundColor,
            colorName = ColorName(rawValue: dappBgColoName) {
                view.backgroundColor = DappColors.colorWithColorName(colorName)
        }
        
        self.initDappScoreLabel(dappScoreLabel, dappScore: dapp?.dappScore)
        
        if let userName = dapp?.name {
            dappSubmitterLabel.text = "From \(userName)"
        } else {
            dappSubmitterLabel.text = ""
        }
    }
    
    // MARK: - private
    
    private class func initDappSubmitterLabelTextWithDapp(dapp: PFObject?,
        dappSubmitterLabel: UILabel!
    ) {
        if let userName = dapp?["name"] as? String {
            dappSubmitterLabel.text = "From \(userName)"
        } else {
            dappSubmitterLabel.text = ""
        }
    }
    
    private class func initDappScoreLabel(dappScoreLabel: UILabel!, dappScore: Int?) {
        guard let dappScore = dappScore else {
            dappScoreLabel.text = "0 Dapps"
            
            return
        }
        
        if dappScore == 1 {
            dappScoreLabel.text = "1 Dapp"
        } else {
            dappScoreLabel.text = "\(dappScore) Dapps"
        }
    }
}
