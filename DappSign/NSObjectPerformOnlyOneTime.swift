//
//  NSObjectPerformOnlyOneTime.swift
//  DappSign
//
//  Created by Admin on 3/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

extension NSObject {
    func perform_only_one_time(closure: () -> ()) {
        struct TokenHolder {
            static var token: dispatch_once_t = 0;
        }
        
        dispatch_once(&TokenHolder.token) {
            closure()
        }
    }
}
