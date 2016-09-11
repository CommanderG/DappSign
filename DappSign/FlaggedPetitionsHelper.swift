//
//  FlaggedPetitionsHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class FlaggedPetitionsHelper: NSObject {
    internal class func flagPetition(petition: PFObject, completion: (success: Bool) -> Void) {
        let flaggedPetition = PFObject(className: "FlaggedPetition")
        
        flaggedPetition["petition"] = petition
        
        flaggedPetition.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) in
            completion(success: success)
            
            if let error = error {
                print("Failed to flag petition. Error: \(error)")
            }
        }
    }
}
