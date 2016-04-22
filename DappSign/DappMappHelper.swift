//
//  DappMappHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/21/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

struct DappMappInfo {
    let IDsFreqs:                          IDsFrequencies
    let mapURLString:                      String?
    let percents:                          UInt
    let districtsWithMajoritySupportCount: Int
}

class DappMappHelper {
    internal class func dappMappInfoForDapp(dapp: PFObject,
        completion: (dappMappInfo: DappMappInfo?) -> Void
    ) {
        Requests.percents(dapp, completion: {
            (usersDapped: [PFUser:Bool]?, error: NSError?) -> Void in
            if let usersDapped = usersDapped {
                if usersDapped.count >= 20 {
                    self.downloadAndGenerateDappMappInfo(usersDapped,
                        dapp: dapp,
                        completion: completion
                    )
                } else {
                    let dappMappInfo = self.generateRandomDappMappInfo()
                    
                    completion(dappMappInfo: dappMappInfo)
                }
            }
        })
    }
    
    // MARK: - private
    
    private class func downloadAndGenerateDappMappInfo(
        usersDapped: [PFUser:Bool],
        dapp: PFObject,
        completion: (dappMappInfo: DappMappInfo?) -> Void
    ) {
        let dapps = Array(usersDapped.values)
        
        CongressionalDistrictsIDs.getIDsFrequenciesForDapp(dapp, completion: {
            (IDsFreqs: IDsFrequencies?) -> Void in
            if let IDsFreqs = IDsFreqs {
                let SVGMapURL = SVGMapGenerator.generate(IDsFreqs)
                let dappedCount = self.calculateDappedCount(usersDapped)
                var percents: UInt = 0
                
                if dappedCount > 0 && dapps.count > 0 {
                    percents = UInt(roundf(Float(dappedCount) / Float(dapps.count) * 100))
                }
                
                let districtsWithMajoritySupportCount =
                self.countDistrictsWithMajoritySupport(usersDapped)
                
                let dappMappInfo = DappMappInfo(
                    IDsFreqs:                          IDsFreqs,
                    mapURLString:                      SVGMapURL,
                    percents:                          percents,
                    districtsWithMajoritySupportCount: districtsWithMajoritySupportCount
                )
                
                completion(dappMappInfo: dappMappInfo)
            } else {
                completion(dappMappInfo: nil)
            }
        })
    }
    
    private class func generateRandomDappMappInfo() -> DappMappInfo {
        var dappsCount = UInt(10 + arc4random_uniform(20))
        var IDsFreqs = CongressionalDistrictsIDs.getRandomIDsFreqs(dappsCount)
        
        var percents: UInt = 0
        let SVGMapURL = SVGMapGenerator.generate(IDsFreqs)
        
        if let
            user = PFUser.currentUser(),
            congrDistrID = user["congressionalDistrictID"] as? String {
                let additionalFreq = UInt(1 + arc4random_uniform(4))
                var dappTotalViews: UInt = 1
                var dappDapps: UInt = 1
                
                if let freq = IDsFreqs[congrDistrID] as UInt? {
                    IDsFreqs[congrDistrID] = freq + additionalFreq
                    
                    dappTotalViews = freq + additionalFreq
                } else {
                    IDsFreqs[congrDistrID] = additionalFreq
                    
                    dappTotalViews = additionalFreq
                }
                
                dappDapps = UInt(arc4random_uniform(UInt32(dappTotalViews)))
                
                if dappDapps == 0 {
                    dappDapps = 1
                } else if dappDapps > dappTotalViews {
                    dappDapps = dappTotalViews
                }
                
                percents = UInt(roundf(Float(dappDapps) / Float(dappTotalViews) * 100))
                
                dappsCount += additionalFreq
        }
        
        let maxRandom = UInt32(roundf(Float(IDsFreqs.count) / 2))
        let districtsWithMajoritySupportCount = Int(1 + arc4random_uniform(maxRandom))
        let dappMappInfo = DappMappInfo(
            IDsFreqs:                          IDsFreqs,
            mapURLString:                      SVGMapURL,
            percents:                          percents,
            districtsWithMajoritySupportCount: districtsWithMajoritySupportCount
        )
        
        return dappMappInfo
    }
    
    private class func calculateDappedCount(usersDapped: [PFUser:Bool]) -> Int {
        let currentUser = PFUser.currentUser()
        let currentUserDistrict = currentUser["congressionalDistrictID"] as? String
        let users = Array(usersDapped.keys)
        
        let dappedCount = users.filter {
            (user: PFUser) -> Bool in
            let userDistrict = user["congressionalDistrictID"] as? String
            
            if let currentUserDistrict = currentUserDistrict, userDistrict = userDistrict {
                if user.objectId == currentUser.objectId {
                    // the back end hasn't been updated yet
                    return true
                }
                
                if currentUserDistrict == userDistrict {
                    if let dapped = usersDapped[user] as Bool? {
                        if dapped == true {
                            return true
                        }
                    }
                }
            }
            
            return false
        }.count
        
        return dappedCount
    }
    
    private class func countDistrictsWithMajoritySupport(usersDapped: [PFUser: Bool]) -> Int {
        var districtsDappedNotDapped: [String: (Int, Int)] = [:]
        
        for (user, userDapped) in usersDapped {
            if let district = user["congressionalDistrictID"] as? String {
                var dappedNotDapped: (Int, Int)
                
                if let x = districtsDappedNotDapped[district] {
                    dappedNotDapped = x
                } else {
                    dappedNotDapped = (0, 0)
                }
                
                if userDapped {
                    districtsDappedNotDapped[district] = (dappedNotDapped.0 + 1, dappedNotDapped.1)
                } else {
                    districtsDappedNotDapped[district] = (dappedNotDapped.0, dappedNotDapped.1 + 1)
                }
            }
        }
        
        var count = 0
        
        for (_, (dapped, notDapped)) in districtsDappedNotDapped {
            if dapped > notDapped {
                ++count
            }
        }
        
        return count
    }
}
