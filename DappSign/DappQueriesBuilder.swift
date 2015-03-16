//
//  DappQueriesBuilder.swift
//  DappSign
//
//  Created by Admin on 3/14/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class DappQueriesBuilder {
    class func predicateForAllDapsOfType(dappType: DappType) -> NSPredicate? {
        switch dappType {
            case .Primary:
                return NSPredicate(
                    format: "isDeleted != true AND dappTypeId = %@", DappTypeId.Primary.rawValue
                )
            case .Secondary:
                return NSPredicate(format:
                    "isDeleted != true AND dappTypeId = %@", DappTypeId.Secondary.rawValue
                )
            case .Unapproved:
                return NSPredicate(format:
                    "isDeleted != true AND dappTypeId = nil"
                )
        }
    }
    
    class func queryForAllDappsOfType(dappType: DappType) -> PFQuery? {
        if let predicate = self.predicateForAllDapsOfType(dappType) {
            let query = PFQuery(className: "Dapps", predicate: predicate)
            
            return query
        }
        
        return nil
    }
}
