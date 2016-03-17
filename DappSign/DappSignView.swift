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
    
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var dappSubmitterLabel: UILabel!
    
    @IBOutlet var arrowImageViewsAndLabels: [UIView]!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.dappSignView = self.viewInXIB
        
        self.dappSignView?.layer.cornerRadius = 12.0
        self.dappSignView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.dappSignView?.layer.borderWidth = 2.0
    }
    
    // MARK: - internal
    
    internal func showDappObject(dapp: PFObject?) {
        if let dapp = dapp {
            self.dappStatementLabel.text = dapp["dappStatement"] as? String
            
            if let
                dappFontName = dapp["dappFont"] as? String,
                fontName = FontName(rawValue: dappFontName) {
                    let fontFileName = DappFonts.fontFileNameWithName(fontName)
                    
                    self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
            }
            
            if let
                dappBgColoName = dapp["dappBackgroundColor"] as? String,
                colorName = ColorName(rawValue: dappBgColoName) {
                    self.dappStatementLabel.backgroundColor =
                        DappColors.colorWithColorName(colorName)
            }
        } else {
            self.dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            
            let fontFileName = DappFonts.fontFileNameWithName(.Exo)
            
            self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
        }
        
        self.dappSignView?.backgroundColor = self.dappStatementLabel.backgroundColor
        self.initDappSubmitterLabelTextWithDapp(dapp)
    }
    
    internal func showDapp(dapp: Dapp?) {
        self.dappStatementLabel.text = dapp?.dappStatement ?? ""
        
        if let dappFontName = dapp?.dappFont, fontName = FontName(rawValue: dappFontName) {
            let fontFileName = DappFonts.fontFileNameWithName(fontName)
            
            self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
        }
        
        if let
            dappBgColoName = dapp?.dappBackgroundColor,
            colorName = ColorName(rawValue: dappBgColoName) {
                self.dappSignView?.backgroundColor = DappColors.colorWithColorName(colorName)
        }
        
        if let userName = dapp?.name {
            self.dappSubmitterLabel.text = "From \(userName)"
        } else {
            self.dappSubmitterLabel.text = ""
        }
    }
    
    // MARK: - private
    
    private func initDappSubmitterLabelTextWithDapp(dapp: PFObject?) {
        if let userName = dapp?["name"] as? String {
            self.dappSubmitterLabel.text = "From \(userName)"
        } else {
            self.dappSubmitterLabel.text = ""
        }
    }
}
