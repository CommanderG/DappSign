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
        
        let newLineString = "\n"
        
        while lowercaseString.containsString(newLineString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                newLineString
            ,   withString: " "
            )
        }
        
        let doubleWhitespaceString = "  "
        
        while lowercaseString.containsString(doubleWhitespaceString) {
            lowercaseString = lowercaseString.stringByReplacingOccurrencesOfString(
                doubleWhitespaceString
            ,   withString: " "
            )
        }
        
        if lowercaseString.characters.count > 0 {
            let firstCharacterIndex = lowercaseString.startIndex
            let firstCharacter = lowercaseString[firstCharacterIndex]
            
            if firstCharacter == " " {
                if lowercaseString.characters.count > 1 {
                    let newStartIndex = lowercaseString.startIndex.advancedBy(1)
                    let newEndIndex = lowercaseString.endIndex.predecessor()
                    
                    lowercaseString = lowercaseString[newStartIndex...newEndIndex]
                } else {
                    lowercaseString = ""
                }
            }
        }
        
        if lowercaseString.characters.count > 0 {
            let lastCharacterIndex = lowercaseString.endIndex.predecessor()
            let lastCharacter = lowercaseString[lastCharacterIndex]
            
            if lastCharacter == " " {
                if lowercaseString.characters.count > 1 {
                    let newStartIndex = lowercaseString.startIndex
                    let newEndIndex = lowercaseString.endIndex.predecessor().predecessor()
                    
                    lowercaseString = lowercaseString[newStartIndex...newEndIndex]
                } else {
                    lowercaseString = ""
                }
            }
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
        
        let stringWords = lowercaseString.componentsSeparatedByString(" ")
        
        for stringWord in stringWords {
            for prohibitedPhrase in singleWordProhibitedPhrases {
                if stringWord == prohibitedPhrase {
                    prohibitedPhrasesInString.append(prohibitedPhrase)
                }
            }
        }
        
        var uniqueProhibitedPhrasesInString: [String] = []
        
        for prohibitedPhrase in prohibitedPhrasesInString {
            if !uniqueProhibitedPhrasesInString.contains(prohibitedPhrase) {
                uniqueProhibitedPhrasesInString.append(prohibitedPhrase)
            }
        }
        
        return uniqueProhibitedPhrasesInString
    }
}
