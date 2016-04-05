//
//  RepresentativeHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/5/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class RepresentativeHelper {
    internal class func districtForRepresentative(representative: PFObject) -> String? {
        let congressionalDistrictID = representative["congressionalDistrictID"] as? String
        
        return congressionalDistrictID
    }
    
    internal class func fullNameForRepresentative(representative: PFObject) -> String? {
        let fullName = representative["Name"] as? String
        
        return fullName
    }
    
    internal class func imageURLForRepresentative(representative: PFObject) -> NSURL? {
        if let
            representativeImageURLString = representative["imgUrl"] as? String,
            representativeImageURL = NSURL(string: representativeImageURLString) {
                return representativeImageURL
        }
        
        return nil
    }
    
    // MARK: - private
    
    private class func distringStringWithInt(district: Int) -> String {
        if district >= 10 {
            return "\(district)"
        }
        
        return "0\(district)"
    }
}
