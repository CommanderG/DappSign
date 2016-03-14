//
//  DappsHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/7/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappsHelper {
    typealias DappDappScore = (PFObject, Int)
    typealias UserDappScore = (PFUser, Int)
    
    internal class func sortDappsByDappScore(
        dapps: [PFObject],
        completion: (sortedDapps: [PFObject]) -> Void
    ) {
        Requests.downloadUsers({
            (users: [PFUser]?, error: NSError?) -> Void in
            if let users = users {
                let usersDappScores = self.usersDappScoresWithUsers(users)
                let dappsDappScores = self.dappsDappScores(dapps)
                
                var newDappsDappScores = self.dappsDappScoresWithUsersDappScores(usersDappScores,
                    addedToDappsDappScores: dappsDappScores
                )
                
                let currentUser = PFUser.currentUser()
                let userCongressionalDistrictID =
                currentUser["congressionalDistrictID"] as? String
                
                if let userCongressionalDistrictID = userCongressionalDistrictID {
                    newDappsDappScores = self.doubleDappsDappScores(newDappsDappScores,
                        userCongressionalDistrictID: userCongressionalDistrictID,
                        users: users
                    )
                }
                
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
                
                completion(sortedDapps: sortedDapps)
            } else {
                completion(sortedDapps: dapps)
            }
        })
    }
    
    private class func usersDappScoresWithUsers(users: [PFUser]) -> [UserDappScore] {
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
            userDappScore -> UserDappScore in
            let (user, dappScore) = userDappScore
            
            return (user, dappScore!)
        })
        
        return usersDappScores
    }
    
    private class func dappsDappScores(dapps: [PFObject]) -> [DappDappScore] {
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
            dappDappScore -> DappDappScore in
            let (dapp, dappScore) = dappDappScore
            
            return (dapp, dappScore!)
        })
        
        return dappsDappScores
    }
    
    private class func dappsDappScoresWithUsersDappScores(
        usersDappScores: [UserDappScore],
        addedToDappsDappScores dappsDappScores: [DappDappScore]
    ) -> [DappDappScore] {
        let newDappsDappScores = dappsDappScores.map({
            dappDappScore -> DappDappScore in
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
        usersDappScores: [UserDappScore]
    ) -> UserDappScore? {
        for userDappScore in usersDappScores {
            let (user, _) = userDappScore
            
            if user.objectId == userID {
                return userDappScore
            }
        }
        
        return nil
    }
    
    private class func doubleDappsDappScores(
        dappsDappScores: [DappDappScore],
        userCongressionalDistrictID: String,
        users: [PFUser]
    ) -> [DappDappScore] {
        let doubleDappsDappScores = dappsDappScores.map({
            dappDappScore -> DappDappScore in
            let (dapp, dappScore) = dappDappScore
            if let
                userID = dapp["userid"] as? String,
                user = self.userWithID(userID, users: users),
                submitterCongressionalDistrictID = user["congressionalDistrictID"] as? String {
                    if userCongressionalDistrictID == submitterCongressionalDistrictID {
                        let newDappScore = dappScore * 2
                        let newDappDappScore = (dapp, newDappScore)
                        
                        return newDappDappScore
                    } else {
                        return dappDappScore
                    }
            } else {
                return dappDappScore
            }
        })
        
        return doubleDappsDappScores
    }
    
    private class func userWithID(userID: String, users: [PFUser]) -> PFUser? {
        for user in users {
            if user.objectId == userID {
                return user
            }
        }
        
        return nil
    }
}
