//
//  DappFonts.swift
//  DigiDappPrototypeZ
//
//  Created by Seshagiri Vakkalanka on 1/24/15.
//  Copyright (c) 2015 DigiDapp. All rights reserved.
//

import Foundation
import UIKit

class DappFonts{
    
    var futura = UIFont(name: "Futura" , size: CGFloat(29.0))
    var baskerville = UIFont(name: "Baskerville" , size: CGFloat(29.0))
    var avenir = UIFont(name: "Avenir" , size: CGFloat(29.0))
    var copperplate = UIFont(name: "Copperplate" , size: CGFloat(29.0))
    var menlo = UIFont(name: "Menlo" , size: CGFloat(29.0))
    var verdana = UIFont(name: "Verdana" , size: CGFloat(29.0))
    var helvetica = UIFont(name: "Helvetica" , size: CGFloat(29.0))
    var didot = UIFont(name: "Didot" , size: CGFloat(29.0))
    
    //new fonts
    var banksia = UIFont(name:"Banksia" , size: CGFloat(29.0))
    var bellota = UIFont(name:"Bellota" , size: CGFloat(29.0))
    var capture = UIFont(name:"Capture it" , size: CGFloat(29.0))
    var elsie = UIFont(name: "Elsie", size: CGFloat(29.0))
    var exo = UIFont(name:"Exo", size: CGFloat(29.0))
    var klinicSlab = UIFont(name:"Klinic Slab", size: CGFloat(29.0))
    var printClearly = UIFont(name:"Print Clearly" , size: CGFloat(29.0))
    var sansation = UIFont(name:"Sansation" , size: CGFloat(29.0))
    var walkwaySemiBold = UIFont(name:"Walkway SemiBold" , size: CGFloat(29.0))

    
    var dappFontBook = [String: UIFont]()
    
    init(){
        
        dappFontBook.updateValue(futura!, forKey: "futura")
        dappFontBook.updateValue(baskerville!, forKey: "baskerville")
        dappFontBook.updateValue(avenir!, forKey: "avenir")
        dappFontBook.updateValue(copperplate!, forKey: "copperplate")
        dappFontBook.updateValue(menlo!, forKey: "menlo")
        dappFontBook.updateValue(verdana!, forKey: "verdana")
        dappFontBook.updateValue(helvetica!, forKey: "helvetica")
        dappFontBook.updateValue(didot!, forKey: "didot")
        dappFontBook.updateValue(banksia!, forKey: "banksia")
        dappFontBook.updateValue(bellota!, forKey: "bellota")
        dappFontBook.updateValue(capture!, forKey: "captureIt")
        dappFontBook.updateValue(elsie!, forKey: "elsie")
        dappFontBook.updateValue(exo!, forKey: "exo")
        dappFontBook.updateValue(klinicSlab!, forKey: "klinicSlab")
        dappFontBook.updateValue(printClearly!, forKey: "printClearly")
        dappFontBook.updateValue(sansation!, forKey: "sansation")
        dappFontBook.updateValue(walkwaySemiBold!, forKey: "walkwaySemiBold")
        
    
    }
}