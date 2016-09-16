//
//  SignHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/16/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class SignHelper {
    internal class func addSignWithPetition(
        petition: PFObject,
        user: PFUser,
        userDistrict: String,
        completion: ((error: NSError?) -> Void)?
    ) {
        let sign = PFObject(className: "Sign")
        
        sign["petition"] = petition
        sign["district"] = userDistrict
        sign["user"] = user
        
        sign.saveInBackgroundWithBlock {
            (succes: Bool, error: NSError?) in
            completion?(error: error)
        }
    }
}
