//
//  ViewHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ViewHelper {
    internal class func initButtonLayer(button: UIButton) {
        self.addBorderToView(button)
        
        button.layer.cornerRadius = 6.0
    }
    
    internal class func initRepresentativeImageViewLayer(imageView: UIImageView) {
        self.addBorderToView(imageView)
        
        let imageViewWidth = CGRectGetWidth(imageView.frame)
        let cornerRadius = imageViewWidth / 2
        
        imageView.layer.cornerRadius = cornerRadius
    }
    
    internal class func disableButton(button: UIButton) {
        button.alpha = 0.5
        button.userInteractionEnabled = false
    }
    
    internal class func enableButton(button: UIButton) {
        button.alpha = 1.0
        button.userInteractionEnabled = true
    }
    
    // MARK: - private
    
    private class func addBorderToView(view: UIView) {
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2.0
    }
}
