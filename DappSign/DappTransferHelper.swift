//
//  DappTransferHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/4/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappTransferHelper {
    typealias completionClosure = (error: NSError?) -> Void
    
    internal class func addDapp(dapp: PFObject,
        toArray dappArray: DappArray,
        completion: completionClosure
    ) {
        DappArraysHelper.addDapp(dapp, toArray: dappArray) {
            (error: NSError?) -> Void in
            if let error = error {
                completion(error: error)
                
                return
            }
            
            if dappArray == .Secondary {
                completion(error: nil)
            } else {
                self.addDappIndexForDapp(dapp, dappArray: dappArray, completion: completion)
            }
        }
    }
    
    internal class func removeDapp(dapp: PFObject,
        fromArray dappArray: DappArray,
        completion: completionClosure
    ) {
        DappArraysHelper.removeDappWithID(dapp.objectId, fromArray: dappArray) {
            (error: NSError?) -> Void in
            if let error = error {
                completion(error: error)
                
                return
            }
            
            DappIndexHelper.deleteDappIndexForDappWithID(dapp.objectId,
                dappArray: dappArray,
                completion: completion
            )
        }
    }
    
    // MARK: - private
    
    private class func addDappIndexForDapp(dapp: PFObject,
        dappArray: DappArray,
        completion: completionClosure
    ) {
        DappIndexHelper.downloadDappIndexesForArrayWithName(dappArray.rawValue, completion: {
            (dappIndexes: [DappIndex]?, error: NSError?) -> Void in
            if let dappIndexes = dappIndexes {
                var index: Int = 0
                
                if let maxIndex = DappIndexHelper.maxIndexInDappIndexes(dappIndexes) {
                    index = maxIndex + 1
                } else {
                    index = 0
                }
                
                let dappIndex = DappIndex(
                    parseObjectID:  "",
                    dappID:         dapp.objectId,
                    dappsArrayName: dappArray.rawValue,
                    index:          index
                )
                
                DappIndexHelper.addDappIndex(dappIndex, completion: completion)
            } else {
                completion(error: error)
            }
        })
    }
}
