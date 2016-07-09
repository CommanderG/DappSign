//
//  NewDappParams.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/7/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

class NewDappParams {
    internal static var colorName : ColorName = .Cinnabar
    internal static var message   : String    = ""
    internal static var hashtags  : String    = ""
    internal static var fontName  : FontName  = .Exo
    
    internal static func setDefaults() {
        self.colorName = .Cinnabar
        self.message   = ""
        self.hashtags  = ""
        self.fontName  = .Exo
    }
}
