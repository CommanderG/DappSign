//
//  DappMappHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/21/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

struct DappMappInfo {
    let IDsFreqs:     IDsFrequencies
    let mapURLString: String?
    let percents:     UInt
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
        usersDapped: [PFObject:Bool],
        dapp: PFObject,
        completion: (dappMappInfo: DappMappInfo?) -> Void
    ) {
        let dapps = Array(usersDapped.values)
        
        CongressionalDistrictsIDs.getIDsFrequenciesForDapp(dapp, completion: {
            (IDsFreqs: IDsFrequencies?) -> Void in
            if let IDsFreqs = IDsFreqs {
                let SVGMapURL = SVGMapGenerator.generate(IDsFreqs)
                let dappedCount = Array(usersDapped.keys).filter({
                    let currentUser = PFUser.currentUser()
                    
                    if let
                        currentUserCongrDistrID = currentUser["congressionalDistrictID"] as? String,
                        userCongrDistrID = $0["congressionalDistrictID"] as? String {
                            if $0.objectId == currentUser.objectId {
                                // the back end hasn't been updated yet
                                return true
                            } else if currentUserCongrDistrID == userCongrDistrID {
                                if let dapped = usersDapped[$0] as Bool? {
                                    if dapped == true {
                                        return true
                                    }
                                }
                            }
                    }
                    
                    return false
                }).count
                
                var percents = 0 as UInt
                
                if dappedCount > 0 && dapps.count > 0 {
                    percents = UInt(roundf(Float(dappedCount) / Float(dapps.count) * 100))
                }
                
                let dappMappInfo = DappMappInfo(
                    IDsFreqs:     IDsFreqs,
                    mapURLString: SVGMapURL,
                    percents:     percents
                )
                
                completion(dappMappInfo: dappMappInfo)
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
        
        let dappMappInfo = DappMappInfo(
            IDsFreqs: IDsFreqs,
            mapURLString: SVGMapURL,
            percents: percents
        )
        
        return dappMappInfo
    }
}
