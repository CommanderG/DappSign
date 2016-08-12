//
//  LocalDataStorage.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/14/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

typealias Time = (Int, Int)

class LocalStorage {
    private static let _KeyUserIsNew                = "userIsNew"
    private static let _KeyAppHasBeenLaunchedBefore = "appHasBeenLaunchedBefore"
    
    // MARK: - userIsNew
    
    internal class func userIsNew() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let userIsNew = userDefaults.boolForKey(_KeyUserIsNew)
        
        return userIsNew
    }
    
    internal class func saveUserIsNew(userIsNew: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setBool(userIsNew, forKey: _KeyUserIsNew)
        userDefaults.synchronize()
    }
    
    // MARK: - appHasBeenLaunchedBefore
    
    internal class func appHasBeenLaunchedBefore() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let appFirstLaunch = userDefaults.boolForKey(_KeyAppHasBeenLaunchedBefore)
        
        return appFirstLaunch
    }
    
    internal class func saveAppHasBeenLaunchedBefore(appHasBeenLaunchedBefore: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setBool(appHasBeenLaunchedBefore, forKey: _KeyAppHasBeenLaunchedBefore)
        userDefaults.synchronize()
    }
}
