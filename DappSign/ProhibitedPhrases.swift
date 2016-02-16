//
//  ProhibitedWords.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/16/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class ProhibitedPhrases {
    private static var _ProhibitedPhrases: [String] = []
    
    class func setProhibitedPhrases(prohibitedPhrases: [String]) -> Void {
        _ProhibitedPhrases = prohibitedPhrases
    }
    
    class func prohibitedPhrasesInString(string: String) -> [String] {
        var lowercaseString = string.lowercaseString
        let doubleWhitespaceString = "  "
        
        while lowercaseString.containsString(doubleWhitespaceString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                doubleWhitespaceString
            ,   withString: " "
            )
        }
        
        let newLineString = "\n"
        
        while lowercaseString.containsString(newLineString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                newLineString
            ,   withString: ""
            )
        }
        
        var prohibitedPhrasesInString: [String] = []
        
        let multipleWordsProhibitedPhrases = _ProhibitedPhrases.filter {
            (prohibitedPhrase: String) -> Bool in
            return prohibitedPhrase.containsString(" ")
        }
        
        for prohibitedPhrase in multipleWordsProhibitedPhrases {
            if let _ = lowercaseString.rangeOfString(prohibitedPhrase) {
                prohibitedPhrasesInString.append(prohibitedPhrase)
            }
        }
        
        let singleWordProhibitedPhrases = _ProhibitedPhrases.filter {
            (prohibitedPhrase: String) -> Bool in
            return !prohibitedPhrase.containsString(" ")
        }
        
        let stringWords = string.componentsSeparatedByString(" ")
        
        for stringWord in stringWords {
            for prohibitedPhrase in singleWordProhibitedPhrases {
                if stringWord == prohibitedPhrase {
                    prohibitedPhrasesInString.append(prohibitedPhrase)
                }
            }
        }
        
        return prohibitedPhrasesInString
    }
}
