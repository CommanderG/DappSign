//
//  PercentsView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 8/31/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class PercentsView: XIBView {
    private let lineWidth: CGFloat = 8.0
    private var fgCircleLayer: CAShapeLayer? = nil
    private var bgCircleLayer: CAShapeLayer? = nil
    
    @IBOutlet var numbersLabel: UILabel!
    
    // MARK: - internal functions
    
    internal func showPercents(percents: UInt) {
        self.fgCircleLayer?.removeFromSuperlayer()
        self.bgCircleLayer?.removeFromSuperlayer()
        
        if percents > 0 && percents <= 100 {
            self.numbersLabel?.text = "\(percents)"
            
            self.showCircleLayers(percents)
        }
    }
    
    // MARK: - private function
    
    private func showCircleLayers(percents: UInt) {
        let startAngle: CGFloat = CGFloat(-M_PI) / CGFloat(2.0)
        let endAngle:   CGFloat = CGFloat(M_PI) * CGFloat(1.5)
        let radius:     CGFloat = CGRectGetWidth(self.bounds) / 2 - self.lineWidth / 2
        let fgCircleEndAngle = startAngle + (endAngle - startAngle) * (CGFloat(percents) / 100.0)
        
        
        
        let fgCircleLayer = CAShapeLayer()
        fgCircleLayer.path = UIBezierPath(
            arcCenter:  CGPointMake(radius + lineWidth / 2, radius + lineWidth / 2)
        ,   radius:     radius
        ,   startAngle: startAngle
        ,   endAngle:   fgCircleEndAngle
        ,   clockwise:  true
        ).CGPath
        fgCircleLayer.fillColor = UIColor.clearColor().CGColor
        fgCircleLayer.strokeColor = UIColor(red:0.403, green:0.666, blue:0.899, alpha:1.0).CGColor
        fgCircleLayer.lineWidth = self.lineWidth
        
        self.layer.addSublayer(fgCircleLayer)
        
        self.fgCircleLayer = fgCircleLayer
        
        
        
        let bgCircleLayer = CAShapeLayer()
        bgCircleLayer.path = UIBezierPath(
            arcCenter:  CGPointMake(radius + lineWidth / 2, radius + lineWidth / 2)
        ,   radius:     radius
        ,   startAngle: fgCircleEndAngle
        ,   endAngle:   startAngle + (endAngle - startAngle)
        ,   clockwise:  true
        ).CGPath
        bgCircleLayer.fillColor = UIColor.clearColor().CGColor
        bgCircleLayer.strokeColor = UIColor.whiteColor().CGColor
        bgCircleLayer.lineWidth = self.lineWidth
        
        self.layer.addSublayer(bgCircleLayer)
        
        self.bgCircleLayer = bgCircleLayer
    }
}
