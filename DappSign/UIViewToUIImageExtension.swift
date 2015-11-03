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
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.renderInContext(context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            let bgImgSize = CGSizeMake(600.0, self.frame.size.height)
            
            if let bgImg = self.getBgImg(bgImgSize),
                   img   = self.addImage(image, toBackgroundImage: bgImg) {
                return img
            }
        }
        
        return nil
    }
    
    private func getBgImg(size: CGSize) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContext(size)
        
        var bgColor: UIColor
        
        if let superviewBgColor = self.superview?.backgroundColor {
            bgColor = superviewBgColor
        } else {
            bgColor = UIColor.whiteColor()
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            CGContextSetFillColorWithColor(context, bgColor.CGColor)
            CGContextFillRect(context, rect)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return img
        }
        
        return nil
    }
    
    private func addImage(fgImg: UIImage, toBackgroundImage bgImg: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bgImg.size, false, 0.0)
        
        bgImg.drawInRect(CGRectMake(0.0, 0.0, bgImg.size.width, bgImg.size.height))
        fgImg.drawInRect(CGRectMake(
            (bgImg.size.width - fgImg.size.width) / 2,
            0.0,
            fgImg.size.width,
            fgImg.size.height)
        )
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return img
    }
}
