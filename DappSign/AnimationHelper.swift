//
//  AnimationHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/19/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class AnimationHelper {
    internal class func animateDappSignView(dappSignView: UIView) {
        let halfSizeScale = CGAffineTransformMakeScale(0.5, 0.5)
        let translateUpBy200px = CGAffineTransformMakeTranslation(0.0, -200.0)
        
        dappSignView.transform = CGAffineTransformConcat(halfSizeScale, translateUpBy200px)
        
        spring(0.5) {
            let fullSizeScale = CGAffineTransformMakeScale(1.0, 1.0)
            let translateToOriginalPosition = CGAffineTransformMakeTranslation(0.0, 0.0)
            
            dappSignView.transform = CGAffineTransformConcat(
                fullSizeScale, translateToOriginalPosition
            )
        }
    }
}
