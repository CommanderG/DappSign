//
//  AnimationHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/19/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class AnimationHelper {
    internal class func showView(view: UIView) {
        self.showView(view, delay: 0.0, completion: nil)
    }
    
    internal class func showView(view: UIView, delay: Double) {
        self.showView(view, delay: delay, completion: nil)
    }
    
    internal class func showView(view: UIView, completion: (Void -> Void)?) {
        self.showView(view, delay: 0.0, completion: completion)
    }
    
    internal class func showView(view: UIView, delay: Double, completion: (Void -> Void)?) {
        self.halfSizeAndMoveUp(view)
        
        let animationDuration = self.getAnimationDuration()
        
        spring(animationDuration,
            animations: {
                self.restoreSizeAndCenter(view)
            },
            delay: delay,
            completion: completion
        )
    }
    
    internal class func hideView(view: UIView, completion: (Void -> Void)?) {
        self.restoreSizeAndCenter(view)
        
        let animationDuration = self.getAnimationDuration()
        
        spring(animationDuration, animations: {
            self.halfSizeAndMoveUp(view)
            view.alpha = 0.0
        }, completion: completion)
    }
    
    // MARK: - 
    
    private class func halfSizeAndMoveUp(view: UIView) {
        let halfSizeScale = CGAffineTransformMakeScale(0.5, 0.5)
        let translateUpBy200px = CGAffineTransformMakeTranslation(0.0, -200.0)
        
        view.transform = CGAffineTransformConcat(halfSizeScale, translateUpBy200px)
    }
    
    private class func restoreSizeAndCenter(view: UIView) {
        let fullSizeScale = CGAffineTransformMakeScale(1.0, 1.0)
        let translateToOriginalPosition = CGAffineTransformMakeTranslation(0.0, 0.0)
        
        view.transform = CGAffineTransformConcat(fullSizeScale, translateToOriginalPosition)
    }
    
    private class func getAnimationDuration() -> Double {
        return 0.5
    }
}
