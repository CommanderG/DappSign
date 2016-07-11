//
//  DappHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappHelper {
    internal static func getFontName(dapp: PFObject) -> FontName? {
        guard
            let dappFontName = dapp["dappFont"] as? String,
            let fontName = FontName(rawValue: dappFontName)
            else { return nil }
        
        return fontName
    }
    
    internal static func getColorName(dapp: PFObject) -> ColorName? {
        guard
            let dappBgColoName = dapp["dappBackgroundColor"] as? String,
            let colorName = ColorName(rawValue: dappBgColoName)
            else { return nil }
        
        return colorName
    }
}
