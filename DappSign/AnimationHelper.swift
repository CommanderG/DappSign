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
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
        
        dappSignView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1.0, 1.0)
            let translate = CGAffineTransformMakeTranslation(0.0, 0.0)
            
            dappSignView.transform = CGAffineTransformConcat(scale, translate)
        }
    }
}
