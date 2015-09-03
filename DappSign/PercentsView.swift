//
//  PercentsView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 8/31/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class PercentsView: UIView {
    var lineWidth: CGFloat = 8.0
    var percents: UInt = 0
    var numbersLabel: UILabel? = nil
    var percentsLabel: UILabel? = nil
    var fgCircleLayer: CAShapeLayer? = nil
    var bgCircleLayer: CAShapeLayer? = nil
    
    // MARK: - init
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    // MARK: - internal functions
    
    internal func showPercents(percents: UInt) {
        self.percents = percents
        
        self.initAndAddLabels()
        
        if self.percents > 0 && self.percents <= 100 {
            self.numbersLabel?.text = "\(self.percents)"
            
            self.showCircleLayers()
        }
    }
    
    // MARK: - private function
    
    private func initAndAddLabels() {
        self.numbersLabel?.removeFromSuperview()
        
        let numbersLabelFrame = CGRectMake(
            self.lineWidth * 2
        ,   CGRectGetHeight(frame) / 4.5
        ,   CGRectGetWidth(frame) - self.lineWidth * 4
        ,   CGRectGetHeight(frame) / 3
        )
        let numbersLabel = UILabel(frame: numbersLabelFrame)
        numbersLabel.backgroundColor = UIColor.clearColor()
        numbersLabel.textAlignment = NSTextAlignment.Center
        numbersLabel.font = UIFont.systemFontOfSize(32.0)
        numbersLabel.textColor = UIColor.whiteColor()
        numbersLabel.adjustsFontSizeToFitWidth = true
        numbersLabel.minimumScaleFactor = 0.5
        numbersLabel.backgroundColor = UIColor.darkGrayColor()
        
        self.numbersLabel = numbersLabel
        
        self.addSubview(numbersLabel)
        
        
        
        self.percentsLabel?.removeFromSuperview()
        
        let percentsLabelFrame = CGRectMake(
            CGRectGetMinX(numbersLabelFrame)
        ,   CGRectGetMaxY(numbersLabelFrame) + CGFloat(4.0)
        ,   CGRectGetWidth(numbersLabelFrame)
        ,   CGRectGetHeight(frame) / 5
        )
        let percentsLabel = UILabel(frame: percentsLabelFrame)
        percentsLabel.backgroundColor = UIColor.clearColor()
        percentsLabel.text = "PERCENT"
        percentsLabel.textAlignment = NSTextAlignment.Center
        percentsLabel.font = UIFont.systemFontOfSize(10.0)
        percentsLabel.textColor = UIColor.whiteColor()
        percentsLabel.adjustsFontSizeToFitWidth = true
        percentsLabel.minimumScaleFactor = 0.5
        percentsLabel.backgroundColor = UIColor.darkGrayColor()
        
        self.percentsLabel = percentsLabel
        
        self.addSubview(percentsLabel)
    }
    
    private func showCircleLayers() {
        self.fgCircleLayer?.removeFromSuperlayer()
        self.bgCircleLayer?.removeFromSuperlayer()
        
        
        
        let startAngle: CGFloat = CGFloat(-M_PI) / CGFloat(2.0)
        let endAngle:   CGFloat = CGFloat(M_PI) * CGFloat(1.5)
        let radius:     CGFloat = CGRectGetWidth(frame) / 2 - lineWidth / 2
        
        
        
        let fgCircleEndAngle = startAngle + (endAngle - startAngle) * (CGFloat(self.percents) / 100.0)
        
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
