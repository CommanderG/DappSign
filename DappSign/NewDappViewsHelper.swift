//
//  NewDappViewsHelper.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/9/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class NewDappViewsHelper {
    private static let springDuration = 0.5
    private static let translateTo0_0 = CGAffineTransformMakeTranslation(0.0, 0.0)
    private static let translateTo0_200 = CGAffineTransformMakeTranslation(0.0, 200.0)
    
    internal static func updateDappMessageTextView(dappMessageTextView: UITextView!) {
        dappMessageTextView.backgroundColor = DappColors.colorWithColorName(
            NewDappParams.colorName
        )
        
        dappMessageTextView.text = NewDappParams.message
        
        let fontFileName = DappFonts.fontFileNameWithName(NewDappParams.fontName)
        
        dappMessageTextView.font = UIFont(name: fontFileName, size: 25.0)
    }
    
    internal static func initDappMessageTextView(dappMessageTextView: UITextView!) {
        dappMessageTextView.layer.cornerRadius = 10.0
        dappMessageTextView.layer.borderColor = UIColor.whiteColor().CGColor
        dappMessageTextView.layer.borderWidth = 2.0
    }
    
    internal static func initButtonsContainerView(buttonsContainerView: UIView!) {
        buttonsContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        buttonsContainerView.layer.borderWidth = 2.0
    }
    
    internal static func initButton(button: UIButton!) {
        button.layer.cornerRadius = 12.0
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2.0
    }
    
    internal static func animateDappMessageContainer(
        dappMessageContainer: SwipeableView!,
        completion: (Void -> Void)?
    ) {
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
        let transform = CGAffineTransformConcat(scale, translate)
        
        dappMessageContainer.transform = transform
        dappMessageContainer.alpha = 0.0
        
        spring(springDuration, animations: {
            let scale = CGAffineTransformMakeScale(1.0, 1.0)
            let transform = CGAffineTransformConcat(scale, translateTo0_0)
            
            dappMessageContainer.transform = transform
            dappMessageContainer.alpha = 1.0
        }, completion: completion)
    }
    
    internal static func animateButtonsContainerView(buttonsContainerView: UIView) {
        buttonsContainerView.alpha = 0.0
        buttonsContainerView.transform = translateTo0_200
        
        spring(springDuration) {
            buttonsContainerView.alpha = 1.0
            buttonsContainerView.transform = translateTo0_0
        }
    }
    
    internal static func animateButtons(buttons: [UIButton]) {
        for button in buttons {
            button.transform = translateTo0_200
        }
        
        spring(springDuration) {
            for button in buttons {
                button.transform = translateTo0_0
            }
        }
    }
}
