//
//  DappsHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/7/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappsHelper {
    internal class func sortSecondaryDapps(
        secondaryDapps: [PFObject],
        completion: (sortedSecondaryDapps: [PFObject]) -> Void
    ) {
        Requests.downloadUsers({
            (users: [PFUser]?, error: NSError?) -> Void in
            if let users = users {
                let usersDappScores = self.usersDappScoresWithUsers(users)
                let dappsDappScores = self.dappsDappScores(secondaryDapps)
                let newDappsDappScores = self.dappsDappScoresWithUsersDappScores(usersDappScores,
                    addedToDappsDappScores: dappsDappScores
                )
                let sortedNewDappsDappScores = newDappsDappScores.sort({
                    (dapp1DappScore, dapp2DappScore) -> Bool in
                    let (_, dappScore1) = dapp1DappScore
                    let (_, dappScore2) = dapp2DappScore
                    
                    if dappScore1 > dappScore2 {
                        return true
                    }
                    
                    return false
                })
                let sortedDapps = sortedNewDappsDappScores.map({
                    dappDappScore -> PFObject in
                    let (dapp, _) = dappDappScore
                    
                    return dapp
                })
                
                completion(sortedSecondaryDapps: sortedDapps)
            } else {
                completion(sortedSecondaryDapps: secondaryDapps)
            }
        })
    }
    
    private class func usersDappScoresWithUsers(users: [PFUser]) -> [(PFUser, Int)] {
        let usersDappScores = users.map({
            user -> (PFUser, Int?) in
            let dappScore = user["dappScore"] as? Int
            let userDappScore = (user, dappScore)
            
            return userDappScore
        }).filter({
            userDappScore -> Bool in
            let (_, dappScore) = userDappScore
            
            if let _ = dappScore {
                return true
            } else {
                return false
            }
        }).map({
            userDappScore -> (PFUser, Int) in
            let (user, dappScore) = userDappScore
            
            return (user, dappScore!)
        })
        
        return usersDappScores
    }
    
    private class func dappsDappScores(dapps: [PFObject]) -> [(PFObject, Int)] {
        let dappsDappScores = dapps.map({
            dapp -> (PFObject, Int?) in
            let dappScore = dapp["dappScore"] as? Int
            let dappDappScore = (dapp, dappScore)
            
            return dappDappScore
        }).filter({
            dappDappScore -> Bool in
            let (_, dappScore) = dappDappScore
            
            if let _ = dappScore {
                return true
            } else {
                return false
            }
        }).map({
            dappDappScore -> (PFObject, Int) in
            let (dapp, dappScore) = dappDappScore
            
            return (dapp, dappScore!)
        })
        
        return dappsDappScores
    }
    
    private class func dappsDappScoresWithUsersDappScores(
        usersDappScores: [(PFUser, Int)],
        addedToDappsDappScores dappsDappScores: [(PFObject, Int)]
    ) -> [(PFObject, Int)] {
        let newDappsDappScores = dappsDappScores.map({
            dappDappScore -> (PFObject, Int) in
            let (dapp, _) = dappDappScore
            
            if let
                userID = dapp["userid"] as? String,
                userDappScore = self.userDappScoreWithUserWithID(userID,
                    usersDappScores: usersDappScores
                ) {
                    let (_, dapp_dappScore) = dappDappScore
                    let (_, user_dappScore) = userDappScore
                    let newDappDappScore = dapp_dappScore + user_dappScore
                    
                    return (dapp, newDappDappScore)
            } else {
                return dappDappScore
            }
        })
        
        return newDappsDappScores
    }
    
    private class func userDappScoreWithUserWithID(
        userID: String,
        usersDappScores: [(PFUser, Int)]
    ) -> (PFUser, Int)? {
        for userDappScore in usersDappScores {
            let (user, _) = userDappScore
            
            if user.objectId == userID {
                return userDappScore
            }
        }
        
        return nil
    }
}
