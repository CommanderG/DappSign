//
//  NewDappHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/9/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

struct Dapp {
    var dappStatement          : String?
    var lowercaseDappStatement : String?
    var dappFont               : String?
    var dappBackgroundColor    : String?
    var name                   : String?
    var userid                 : String?
    var dappScore              : Int
    var isDeleted              : Bool
    var hashtagNames           : [String]
}

class NewDappHelper {
    internal static func getNewDapp() -> Dapp {
        let user                   = PFUser.currentUser()
        let dappStatement          = NewDappParams.message
        let lowercaseDappStatement = NewDappParams.message.lowercaseString
        let dappFont               = NewDappParams.fontName.rawValue
        let dappBackgroundColor    = NewDappParams.colorName.rawValue
        let name                   = user["name"] as? String
        let userid                 = user.objectId
        let dappScore              = 1
        let isDeleted              = false
        let hashtagNames           = self.getHashtagNames()
        
        let dapp = Dapp(
            dappStatement          :          dappStatement,
            lowercaseDappStatement : lowercaseDappStatement,
            dappFont               :               dappFont,
            dappBackgroundColor    :    dappBackgroundColor,
            name                   :                   name,
            userid                 :                 userid,
            dappScore              :              dappScore,
            isDeleted              :              isDeleted,
            hashtagNames           :           hashtagNames
        )
        
        return dapp
    }
    
    // MARK: - private
    
    private static func getHashtagNames() -> [String] {
        let hashtagNames = NewDappParams.hashtags.characters
            .split(" ")
            .map{ String($0) }
            .map {
                // removes #
                $0[1...$0.characters.count - 1]
        }
        
        return hashtagNames
    }
}
