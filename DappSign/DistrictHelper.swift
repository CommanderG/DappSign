//
//  DistrictHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DistrictHelper {
    internal class func calculateDappScoreForDistrict(district: String,
        completion: (dappScore: Int?, error: NSError?) -> Void
    ) {
        UserHelper.downloadAllUsersWithDistrict(district) {
            (users: [PFUser]?, error: NSError?) -> Void in
            if let users = users {
                DappsHelper.downloadAllDapps {
                    (dapps: [PFObject]?, error: NSError?) -> Void in
                    if let dapps = dapps {
                        let dappsCreatedByUsers = self.dappsWithDapps(dapps, createdByUsers: users)
                        let dappScore = DappsHelper.sumDappScoreOfDapps(dappsCreatedByUsers)
                        
                        completion(dappScore: dappScore, error: nil)
                    } else {
                        completion(dappScore: nil, error: error)
                    }
                }
            } else {
                completion(dappScore: nil, error: error)
            }
        }
    }
    
    // MARK: -
    
    private class func dappsWithDapps(dapps: [PFObject],
        createdByUsers users: [PFUser]
    ) -> [PFObject] {
        let userIDs = users.map {
            (user: PFUser) -> String? in
            return user.objectId
        }.filter {
            (userID: String?) -> Bool in
            if let _ = userID {
                return true
            }
            
            return false
        }.map {
            (userID: String?) -> String in
            return userID!
        }
        
        let dappsCreatedByUsers = dapps.filter {
            (dapp: PFObject) -> Bool in
            if let userID = dapp["userid"] as? String {
                if userIDs.contains(userID) {
                    return true
                }
            }
            
            return false
        }
        
        return dappsCreatedByUsers
    }
}
