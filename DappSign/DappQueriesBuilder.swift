//
//  DappQueriesBuilder.swift
//  DappSign
//
//  Created by Admin on 3/14/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

class DappQueriesBuilder {
    class func queryForAllDappsOfType(dappType: DappType) -> PFQuery? {
        if let predicate = self.predicateForAllDapsOfType(dappType) {
            let query = PFQuery(className: "Dapps", predicate: predicate)
            
            if dappType == .Primary {
                query.orderByAscending("createdAt")
            }
            
            return query
        }
        
        return nil
    }
    
    class func queryForAllDapsNotSwipedByUser(dappType: DappType, user: PFUser) -> PFQuery? {
        let dappsSwipedRelation = user.relationForKey("dappsSwiped")
        let dappsSwipedRelationQuery = dappsSwipedRelation.query()
        let allDappsQuery = self.queryForAllDappsOfType(dappType)
        
        allDappsQuery?.whereKey("objectId",
            doesNotMatchKey: "objectId",
            inQuery: dappsSwipedRelationQuery
        )
        
        allDappsQuery?.whereKey("userid", notEqualTo: user.objectId)
        
        return allDappsQuery
    }
    
    class func queryForAllDappsNotSwipedByUser(user: PFUser, dappStatementSubstring: String) -> PFQuery? {
        let dappsSwipedRelation = user.relationForKey("dappsSwiped")
        let dappsSwipedRelationQuery = dappsSwipedRelation.query()
        let predicate = NSPredicate(format: "isDeleted != true")
        let allDappsQuery = PFQuery(className: "Dapps", predicate: predicate)
        
        allDappsQuery?.whereKey("objectId",
            doesNotMatchKey: "objectId",
            inQuery: dappsSwipedRelationQuery
        )
        
        allDappsQuery.whereKey("userid", notEqualTo: user.objectId)
        allDappsQuery.whereKeyExists("dappTypeId")
        allDappsQuery.orderByAscending("createdAt")
        
        return allDappsQuery
    }
    
    class func queryForDownloadingDappWithID(dappID: String) -> PFQuery {
        let query = PFQuery(className: "Dapps")
        
        query.whereKey("objectId", equalTo: dappID)
        
        return query
    }
    
    class func queryForDownloadingDappsNotSwipedByUser(user: PFUser, withHashtag hashtag: PFObject) -> PFQuery? {
        let dappsSwipedRelation = user.relationForKey("dappsSwiped")
        let dappsSwipedRelationQuery = dappsSwipedRelation.query()
        let predicate = NSPredicate(format: "isDeleted != true")
        let dappsQuery = PFQuery(className: "Dapps", predicate: predicate)
        
        dappsQuery.whereKey("hashtags", containedIn: [hashtag])
        dappsQuery.whereKey("userid", notEqualTo: user.objectId)
        dappsQuery.orderByAscending("createdAt")
        dappsQuery.whereKey("objectId",
            doesNotMatchKey: "objectId",
            inQuery: dappsSwipedRelationQuery
        )
        
        return dappsQuery
    }
    
    // MARK: -
    
    private class func predicateForAllDapsOfType(dappType: DappType) -> NSPredicate? {
        var dappTypeId = ""
        
        switch dappType {
        case .Primary:
            dappTypeId = DappTypeId.Primary.rawValue
        case .Secondary:
            dappTypeId = DappTypeId.Secondary.rawValue
        case .Introductory:
            dappTypeId = DappTypeId.Introductory.rawValue
        }
        
        let predicate = NSPredicate(
            format: "isDeleted != true AND dappTypeId = %@", dappTypeId
        )
        
        return predicate
    }
}
