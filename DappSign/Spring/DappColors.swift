//
//  DappColors.swift
//  DigiDappPrototypeZ
//
//  Created by Seshagiri Vakkalanka on 1/24/15.
//  Copyright (c) 2015 DigiDapp. All rights reserved.
//

import Foundation
import UIKit

enum ColorName: String {
    case Red            = "red"
    case White          = "white"
    case Blue           = "blue"
    case Black          = "black"
    case Yellow         = "yellow"
    case Green          = "green"
    case Purple         = "purple"
    case LightGray      = "lightGray"
    case Gray           = "gray"
    case DarkGray       = "darkGray"
    case Cyan           = "cyan"
    case Brown          = "brown"
    case Magenta        = "magenta"
    case Turquoise      = "turquoise"
    case Emerald        = "emerald"
    case PeterRiver     = "peterRiver"
    case Amethyst       = "amethyst"
    case WetAsphalt     = "wetAsphalt"
    case GreenSea       = "greenSea"
    case Nephritis      = "nephritis"
    case BelizeHole     = "belizeHole"
    case Wisteria       = "wisteria"
    case MidnightBlue   = "midnightBlue"
    case SunFlower      = "sunFlower"
    case Carrot         = "carrot"
    case Alizarin       = "alizarin"
    case Clouds         = "clouds"
    case Concrete       = "concrete"
    case Orange         = "orange"
    case Pumpkin        = "pumpkin"
    case Pomegranate    = "pomegranate"
    case Silver         = "silver"
    case Asbestos       = "asbestos"
    case Cinnabar       = "cinnabar"
    case SummerSky      = "summerSky"
    case Saffron        = "saffron"
    case Cello          = "cello"
    case MediumCarmine  = "mediumCarmine"
    case MediumSeaGreen = "mediumSeaGreen"
    case LightSeaGreen  = "lightSeaGreen"
    case DeepLilac      = "deepLilac"
    case Gamboge        = "gamboge"
}

class DappColors {
    internal class func colorWithColorName(colorName: ColorName) -> UIColor {
        switch colorName {
        case .Red:
            return UIColor.redColor()
        case .White:
            return UIColor.whiteColor()
        case .Blue:
            return UIColor.blueColor()
        case .Black:
            return UIColor.blackColor()
        case .Yellow:
            return UIColor.yellowColor()
        case .Green:
            return UIColor.greenColor()
        case .Purple:
            return UIColor.purpleColor()
        case .LightGray:
            return UIColor.lightGrayColor()
        case .Gray:
            return UIColor.grayColor()
        case .DarkGray:
            return UIColor.darkGrayColor()
        case .Cyan:
            return UIColor.cyanColor()
        case .Brown:
            return UIColor.brownColor()
        case .Magenta:
            return UIColor.magentaColor()
        case .Turquoise:
            return self.colorWithRed(26.0, green: 188.0, blue: 156.0, alpha: 1.0)
        case .Emerald:
            return self.colorWithRed(46.0, green: 204.0, blue: 113.0, alpha: 1.0)
        case .PeterRiver:
            return self.colorWithRed(52.0, green: 152.0, blue: 219.0, alpha: 1.0)
        case .Amethyst:
            return self.colorWithRed(155.0, green: 89.0, blue: 182.0, alpha: 1.0)
        case .WetAsphalt:
            return self.colorWithRed(52.0, green: 73.0, blue: 94.0, alpha: 1.0)
        case .GreenSea:
            return self.colorWithRed(22.0, green: 160.0, blue: 133.0, alpha: 1.0)
        case .Nephritis:
            return self.colorWithRed(39.0, green: 174.0, blue: 96.0, alpha: 1.0)
        case .BelizeHole:
            return self.colorWithRed(41.0, green: 128.0, blue: 185.0, alpha: 1.0)
        case .Wisteria:
            return self.colorWithRed(142.0, green: 68.0, blue: 173.0, alpha: 1.0)
        case .MidnightBlue:
            return self.colorWithRed(44.0, green: 62.0, blue:80.0, alpha: 1.0)
        case .SunFlower:
            return self.colorWithRed(241.0, green: 196.0, blue: 15.0, alpha: 1.0)
        case .Carrot:
            return self.colorWithRed(230.0, green: 126.0, blue: 34.0, alpha: 1.0)
        case .Alizarin:
            return self.colorWithRed(231.0, green: 76.0, blue: 60.0, alpha: 1.0)
        case .Clouds:
            return self.colorWithRed(236.0, green: 240.0, blue: 241.0, alpha: 1.0)
        case .Concrete:
            return self.colorWithRed(142.0, green: 68.0, blue: 173.0, alpha: 1.0)
        case .Orange:
            return self.colorWithRed(243.0, green: 156.0, blue: 18.0, alpha: 1.0)
        case .Pumpkin:
            return self.colorWithRed(211.0, green: 84.0, blue: 0.0, alpha: 1.0)
        case .Pomegranate:
            return self.colorWithRed(192.0, green: 57.0, blue: 43.0, alpha: 1.0)
        case .Silver:
            return self.colorWithRed(189.0, green: 195.0, blue: 199.0, alpha: 1.0)
        case .Asbestos:
            return self.colorWithRed(127.0, green: 140.0, blue: 141.0, alpha: 1.0)
        case .Cinnabar:
            return self.colorWithHexString("#E54D42")
        case .SummerSky:
            return self.colorWithHexString("#3A99D9")
        case .Saffron:
            return self.colorWithHexString("#F0C330")
        case .Cello:
            return self.colorWithHexString("#34495D")
        case .MediumCarmine:
            return self.colorWithHexString("#BE3A30")
        case .MediumSeaGreen:
            return self.colorWithHexString("#2ECC71")
        case .LightSeaGreen:
            return self.colorWithHexString("#1ABC9C")
        case .DeepLilac:
            return self.colorWithHexString("#9B59B6")
        case .Gamboge:
            return self.colorWithHexString("#F39C12")
        }
    }
    
    private class func colorWithRed(red: CGFloat,
                                    green: CGFloat,
                                    blue: CGFloat,
                                    alpha: CGFloat) -> UIColor {
        let r = red / 255.0
        let g = green / 255.0
        let b = blue / 255.0
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        return color
    }
    
    private class func colorWithHexString(hexString: String) -> UIColor {
        var uppercaseHexString = hexString.uppercaseString
        
        if uppercaseHexString.hasPrefix("#") {
            uppercaseHexString = (uppercaseHexString as NSString).substringFromIndex(1)
        }
        
        if uppercaseHexString.characters.count != 6 {
            return UIColor.grayColor()
        }
        
        var rgbValue : UInt32 = 0
        
        NSScanner(string: uppercaseHexString).scanHexInt(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        return color
    }
}
