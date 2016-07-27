//
//  Colors.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/27/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class Colors {
    internal class func getViewControllerBackgroundColor() -> UIColor {
        /*
         Google Blue
         Hex: #4885ed
         RGB: 72, 133, 237
         */
        return UIColor(red: 72.0 / 255.0, green: 133.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
    
    internal class func getLightBlueColor() -> UIColor {
        return UIColor(red: 124.0 / 255.0, green: 167.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
}
