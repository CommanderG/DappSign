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
        view: UIView!
    ) {
        if let dapp = dapp {
            dappStatementLabel.text = dapp["dappStatement"] as? String
            
            if let
                dappFontName = dapp["dappFont"] as? String,
                fontName = FontName(rawValue: dappFontName) {
                    let fontFileName = DappFonts.fontFileNameWithName(fontName)
                    
                    dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
            }
            
            if let
                dappBgColoName = dapp["dappBackgroundColor"] as? String,
                colorName = ColorName(rawValue: dappBgColoName) {
                    dappStatementLabel.backgroundColor = DappColors.colorWithColorName(colorName)
            }
        } else {
            dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            
            let fontFileName = DappFonts.fontFileNameWithName(.Exo)
            
            dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
        }
        
        view.backgroundColor = dappStatementLabel.backgroundColor
        self.initDappSubmitterLabelTextWithDapp(dapp, dappSubmitterLabel: dappSubmitterLabel)
    }
    
    internal class func showDapp(dapp: Dapp?,
        dappStatementLabel: UILabel!,
        dappSubmitterLabel: UILabel!,
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
}
