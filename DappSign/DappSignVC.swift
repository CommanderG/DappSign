//
//  DappSignVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappSignVC: UIViewController {
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var dappSubmitterLabel: UILabel!
    
    internal static let embedSegueID: String = "embedDappSignVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        self.view.backgroundColor = self.dappStatementLabel.backgroundColor
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
                self.view.backgroundColor = DappColors.colorWithColorName(colorName)
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
