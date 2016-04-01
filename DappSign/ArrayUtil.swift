//
//  ArrayUtil.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/1/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ArrayUtil {
    internal class func findElement<T>(fn: T -> Bool, inArray array: [T]) -> T? {
        for element in array {
            if fn(element) {
                return element
            }
        }
        
        return nil
    }
    
    internal class func removeDuplicatesIn<T: Comparable>(array: [T]) -> [T] {
        var uniqueArray: [T] = []
        
        for element in array {
            let count = self.countElement(element, inArray: array)
            
            if count == 1 {
                uniqueArray.append(element)
            }
        }
        
        return uniqueArray
    }
    
    internal class func countElement<T: Comparable>(elementToCount: T, inArray array: [T]) -> Int {
        var count = 0
        
        for element in array {
            if element == elementToCount {
                ++count
            }
        }
        
        return count
    }
}
