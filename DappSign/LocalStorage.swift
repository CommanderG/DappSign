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
    private static let _KeyDailyDappStartTime = "dailyDappStartTime"
    
    internal class func dailyDappStartTime() -> Time? {
        return nil
    }
    
    internal class func saveDailyDappStartTime(time: Time) {
        
    }
}
