//
//  DappFonts.swift
//  DigiDappPrototypeZ
//
//  Created by Seshagiri Vakkalanka on 1/24/15.
//  Copyright (c) 2015 DigiDapp. All rights reserved.
//

import Foundation
import UIKit

enum FontName: String {
    case Futura          = "futura"
    case Baskerville     = "baskerville"
    case Avenir          = "avenir"
    case Copperplate     = "copperplate"
    case Menlo           = "menlo"
    case Verdana         = "verdana"
    case Helvetica       = "helvetica"
    case Didot           = "didot"
    case Banksia         = "banksia"
    case Bellota         = "bellota"
    case CaptureIt       = "captureIt"
    case Elsie           = "elsie"
    case Exo             = "exo"
    case KlinicSlab      = "klinicSlab"
    case PrintClearly    = "printClearly"
    case Sansation       = "sansation"
    case WalkwaySemiBold = "walkwaySemiBold"
}

class DappFonts {
    internal class func fontFileNameWithName(fontName: FontName) -> String {
        switch fontName {
        case .Futura:
            return "Futura"
        case .Baskerville:
            return "Baskerville"
        case .Avenir:
            return "Avenir"
        case .Copperplate:
            return "Copperplate"
        case .Menlo:
            return "Menlo"
        case .Verdana:
            return "Verdana"
        case .Helvetica:
            return "Helvetica"
        case .Didot:
            return "Didot"
        case .Banksia:
            return "Banksia"
        case .Bellota:
            return "Bellota"
        case .CaptureIt:
            return "Capture it"
        case .Elsie:
            return "Elsie"
        case .Exo:
            return "Exo"
        case .KlinicSlab:
            return "Klinic Slab"
        case .PrintClearly:
            return "Print Clearly"
        case .Sansation:
            return "Sansation"
        case .WalkwaySemiBold:
            return "Walkway SemiBold"
        }
    }
    
    internal class func fontDisplayNameWithFontName(fontName: FontName) -> String {
        switch fontName {
        case .Futura:
            return "Futura"
        case .Baskerville:
            return "Baskerville"
        case .Avenir:
            return "Avenir"
        case .Copperplate:
            return "Copperplate"
        case .Menlo:
            return "Menlo"
        case .Verdana:
            return "Verdana"
        case .Helvetica:
            return "Helvetica"
        case .Didot:
            return "Didot"
        case .Banksia:
            return "Banksia"
        case .Bellota:
            return "Bellota"
        case .CaptureIt:
            return "Capture"
        case .Elsie:
            return "Elsie"
        case .Exo:
            return "Exo"
        case .KlinicSlab:
            return "Klinic"
        case .PrintClearly:
            return "PrintClearly"
        case .Sansation:
            return "Sansation"
        case .WalkwaySemiBold:
            return "Walkway"
        }
    }
}
