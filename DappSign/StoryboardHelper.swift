//
//  StoryboardHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/5/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class StoryboardHelper {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    internal class func instantiateProfileDappMappVC() -> ProfileDappMappVC? {
        let storyboardID = "profileDappMappVC"
        
        let profileDappMappVC =
        storyboard.instantiateViewControllerWithIdentifier(storyboardID) as? ProfileDappMappVC
        
        return profileDappMappVC
    }
}
