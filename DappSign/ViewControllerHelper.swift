//
//  ViewControllerHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ViewControllerHelper {
    internal class func openLinkWithURL(linkURL: NSURL,
        inViewController viewController: UIViewController
    ) -> LinkVC? {
        guard let linkVC = StoryboardHelper.instantiateLinkVC() else {
            return nil
        }
        
        viewController.addChildViewController(linkVC)
        
        linkVC.view.frame = viewController.view.bounds
        
        viewController.view.addSubview(linkVC.view)
        
        linkVC.didMoveToParentViewController(viewController)
        linkVC.openURL(linkURL)
        
        AnimationHelper.showView(linkVC.view)
        
        return linkVC
    }
}
