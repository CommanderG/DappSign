//
//  SwipeableView.swift
//  SwipeTest
//
//  Created by Oleksiy Kovtun on 9/14/15.
//  Copyright (c) 2015 Yanpix. All rights reserved.
//

import UIKit

internal enum SwipeDirection {
    case LeftToRight
    case RightToLeft
}

protocol SwipeableViewAppearanceDelegate {
    func willShow(swipeDirection: SwipeDirection)
}

protocol SwipeableViewMovementDelegate {
    func didSwipe(swipeDirection: SwipeDirection)
    func didChangeDistanceFromCenter(dx: CGFloat, andDeltaY dy: CGFloat)
    func didStartMoving()
    func didStopMoving()
}

class SwipeableView: UIView {
    private var originalCenter = CGPointZero
    private var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var gravity: UIGravityBehavior?
    private var swipeDirection: SwipeDirection?
    
    internal var minTranslationX: CGFloat?
    internal var appearanceDelegate: SwipeableViewAppearanceDelegate? = nil
    internal var movementDelegate: SwipeableViewMovementDelegate? = nil
    internal var canBeDraged: Bool = true
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addPanGesture()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.addPanGesture()
        
        self.originalCenter = self.center
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            self.animator = UIDynamicAnimator(referenceView: superview)
            
            self.snapBehavior = UISnapBehavior(item: self, snapToPoint: self.originalCenter)
            
            self.snapBehavior?.damping = 0.4
            
            self.gravity = UIGravityBehavior(items: [self])
            
            self.gravity?.action = {
                if (CGRectGetMinY(self.frame) > CGRectGetHeight(superview.frame) ||
                    CGRectGetMaxY(self.frame) < 0.0) {
                        self.show()
                }
            }
        }
    }
    
    private func addPanGesture() {
        let panGR = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        
        self.addGestureRecognizer(panGR)
    }
    
    internal func show() {
        if let swipeDirection = self.swipeDirection {
            self.appearanceDelegate?.willShow(swipeDirection)
        }
        
        self.animator?.removeAllBehaviors()
        
        self.center = self.originalCenter
        
        AnimationHelper.showView(self)
    }
    
    // MARK: - pan gesture recognizer
    
    internal func handlePanGesture(panGR: UIPanGestureRecognizer) {
        if !self.canBeDraged {
            return
        }
        
        let translation = panGR.translationInView(self)
        
        switch panGR.state {
        case .Began:
            self.animator?.removeAllBehaviors()
            self.movementDelegate?.didStartMoving()
            
            break
        case .Changed:
            let defaultRotationAngle = CGFloat(M_PI) / 10.0
            let rotationMax: CGFloat = 1.0
            let xRotationStrength = min(translation.x / self.frame.size.width, rotationMax)
            let yRotationStrength = min(translation.y / self.frame.size.height, rotationMax)
            let rotationAngle = defaultRotationAngle * xRotationStrength * yRotationStrength
            
            self.transform = CGAffineTransformMakeRotation(rotationAngle)
            self.center = CGPoint(
                x: self.originalCenter.x + translation.x,
                y: self.originalCenter.y + translation.y
            )
            
            let dx = self.originalCenter.x - self.center.x
            let dy = self.originalCenter.y - self.center.y
            
            self.movementDelegate?.didChangeDistanceFromCenter(dx, andDeltaY: dy)
            
            break
        case .Ended:
            self.swipeDirection = nil
            
            if let minTranslationX = self.minTranslationX {
                if translation.x >= minTranslationX {
                    self.swipeDirection = SwipeDirection.LeftToRight
                } else if translation.x <= -minTranslationX {
                    self.swipeDirection = SwipeDirection.RightToLeft
                }
            }
            
            if let swipeDir = self.swipeDirection {
                switch swipeDir {
                case .LeftToRight:
                    self.gravity?.gravityDirection = CGVectorMake(0.0, -10.0)
                case .RightToLeft:
                    self.gravity?.gravityDirection = CGVectorMake(0.0, 10.0)
                }
                
                if let gravity = self.gravity {
                    self.animator?.addBehavior(gravity)
                }
                
                if let swipeDirection = self.swipeDirection {
                    self.movementDelegate?.didSwipe(swipeDirection)
                }
            } else {
                if let snapBehavior = self.snapBehavior {
                    self.animator?.addBehavior(snapBehavior)
                }
            }
            
            self.movementDelegate?.didStopMoving()
            
            break
        default:
            break
        }
    }
}
