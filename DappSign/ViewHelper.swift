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
    
    // MARK: - enabling/disabling views
    
    internal class func enableViews(views: [UIView]) {
        for view in views {
            self.enableView(view)
        }
    }
    
    internal class func disableViews(views: [UIView]) {
        for view in views {
            self.disableView(view)
        }
    }
    
    // MARK: - enabling/disabling buttons
    
    internal class func enableButtons(buttons: [UIButton!]) {
        for button in buttons {
            self.enableView(button)
        }
    }
    
    internal class func disableButtons(buttons: [UIButton!]) {
        for button in buttons {
            self.disableView(button)
        }
    }
    
    // MARK: - private
    
    private class func addBorderToView(view: UIView) {
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2.0
    }
    
    // MARK: - enabling/disabling views
    
    private class func enableView(view: UIView) {
        view.userInteractionEnabled = true
        view.alpha = 1.0
    }
    
    private class func disableView(view: UIView) {
        view.userInteractionEnabled = false
        view.alpha = 0.5
    }
}
