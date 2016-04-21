//
//  PercentsVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class PercentsVC: UIViewController {
    @IBOutlet weak var percentNumberLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var leadingSpaceLC: NSLayoutConstraint!
    
    internal static let embedSegueID = "embedPercentsVC"
    
    private var fgCircleLayer: CAShapeLayer? = nil
    private var bgCircleLayer: CAShapeLayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - internal
    
    internal func showPercents(percents: UInt) {
        self.percentNumberLabel.text = "\(percents)"
        
        let leadingSpace = CGRectGetWidth(self.view.frame) / 6
        
        let viewWidth = CGRectGetWidth(self.view.frame)
        let percentLabelNewWidth = viewWidth - leadingSpace * 2
        let percentNumberLabel = viewWidth / 3
        
        self.changeFontInLabel(self.percentNumberLabel,
            toFitInNewWidth: percentNumberLabel,
            labelText: "100"
        )
        self.changeFontInLabel(self.percentLabel,
            toFitInNewWidth: percentLabelNewWidth,
            labelText: self.percentLabel.text
        )
        
        self.leadingSpaceLC.constant = leadingSpace
        
        self.fgCircleLayer?.removeFromSuperlayer()
        self.bgCircleLayer?.removeFromSuperlayer()
        self.showCircleLayers(percents)
    }
    
    // MARK: - private
    
    private func showCircleLayers(percents: UInt) {
        let lineWidth: CGFloat = 4.0
        let startAngle = CGFloat(-M_PI) / CGFloat(2.0)
        let endAngle = CGFloat(M_PI) * CGFloat(1.5)
        let radius = CGRectGetWidth(self.view.bounds) / 2 - lineWidth / 2
        let fgCircleEndAngle = startAngle + (endAngle - startAngle) * (CGFloat(percents) / 100.0)
        let fgCircleLayer = CAShapeLayer()
        
        fgCircleLayer.path = UIBezierPath(
            arcCenter:  CGPointMake(radius + lineWidth / 2, radius + lineWidth / 2),
            radius:     radius,
            startAngle: startAngle,
            endAngle:   fgCircleEndAngle,
            clockwise:  true
        ).CGPath
        fgCircleLayer.fillColor = UIColor.clearColor().CGColor
        fgCircleLayer.strokeColor = UIColor(
            red:   3.0 / 255.0,
            green: 103.0 / 255.0,
            blue:  180.0 / 255.0,
            alpha: 1.0
            ).CGColor
        fgCircleLayer.lineWidth = lineWidth
        
        self.view.layer.addSublayer(fgCircleLayer)
        
        self.fgCircleLayer = fgCircleLayer
        
        let bgCircleLayer = CAShapeLayer()
        
        bgCircleLayer.path = UIBezierPath(
            arcCenter:  CGPointMake(radius + lineWidth / 2, radius + lineWidth / 2),
            radius:     radius,
            startAngle: fgCircleEndAngle,
            endAngle:   startAngle + (endAngle - startAngle),
            clockwise:  true
        ).CGPath
        bgCircleLayer.fillColor = UIColor.clearColor().CGColor
        bgCircleLayer.strokeColor = UIColor(
            red:   212.0 / 255.0,
            green: 212.0 / 255.0,
            blue:  212.0 / 255.0,
            alpha: 1.0
            ).CGColor
        bgCircleLayer.lineWidth = lineWidth
        
        self.view.layer.addSublayer(bgCircleLayer)
        
        self.bgCircleLayer = bgCircleLayer
    }
    
    private func changeFontInLabel(label: UILabel,
        toFitInNewWidth width: CGFloat,
        labelText: String?
    ) {
        if let labelText = labelText {
            let originalFontSize = label.font.pointSize
            var fontSize: CGFloat = 100.0
            
            repeat {
                label.font = label.font.fontWithSize(fontSize)
                
                let attributes = [ NSFontAttributeName: label.font ]
                let labelSize = labelText.sizeWithAttributes(attributes)
                
                if labelSize.width <= width {
                    return
                }
                
                --fontSize
            } while (fontSize > 0)
            
            label.font = label.font.fontWithSize(originalFontSize)
        }
    }
}
