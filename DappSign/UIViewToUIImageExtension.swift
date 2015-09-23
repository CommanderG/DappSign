//
//  UIViewToUIImageExtension.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, 1.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.renderInContext(context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return image
        }
        
        return nil
    }
}
