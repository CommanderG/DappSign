//
//  HashtagHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class HashtagHelper {
    internal class func hashtagNamesStringWithHashtags(hashtags: [PFObject]) -> String {
        let hashtagNames = hashtags.map {
            (hashtag: PFObject) -> String? in
            let hashtagName = hashtag["name"] as? String
            
            return hashtagName
            }.filter {
                (hashtagName: String?) -> Bool in
                if let _ = hashtagName {
                    return true
                }
                
                return false
            }.map {
                (hashtagName: String?) -> String in
                return "#" + hashtagName!
        }
        
        let hashtagNamesString = hashtagNames.joinWithSeparator(" ")
        
        return hashtagNamesString
    }
}
