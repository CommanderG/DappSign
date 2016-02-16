//
//  ProhibitedWords.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/16/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class ProhibitedWords {
    private static var _ProhibitedWords: [String] = []
    
    class func setProhibitedWords(prohibitedWords: [String]) -> Void {
        _ProhibitedWords = prohibitedWords
    }
    
// FIXME: prohibitedWordsInString("assimilation") should not return ["ass"]
    class func prohibitedWordsInString(string: String) -> [String] {
        var lowercaseString = string.lowercaseString
        lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString("  ", withString: " ")
        lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        var prohibitedWordsInString: [String] = []
        
        for prohibitedWord in _ProhibitedWords {
            if let _ = lowercaseString.rangeOfString(prohibitedWord) {
                prohibitedWordsInString.append(prohibitedWord)
            }
        }
        
        return prohibitedWordsInString
    }
}
