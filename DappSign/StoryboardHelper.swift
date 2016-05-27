//
//  StoryboardHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/5/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class StoryboardHelper {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    internal class func instantiateProfileDappMappVC() -> ProfileDappMappVC? {
        return self.viewControllerWithID("profileDappMappVC")
    }
    
    internal class func instantiateEmbedDappVC() -> EmbedDappVC? {
        return self.viewControllerWithID("embedDappVC")
    }
    
    internal class func instantiateDailyDappVC() -> DailyDappVC? {
        return self.viewControllerWithID("dailyDappVC")
    }
    
    internal class func instantiateLinkVC() -> LinkVC? {
        return self.viewControllerWithID("LinkVC")
    }
    
    internal class func instantiateScoreboardVC() -> ScoreboardVC? {
        return self.viewControllerWithID("scoreboardVC")
    }
    
    internal class func instantiateScoreboardDappSignFrontSideVC(
    ) -> ScoreboardDappSignFrontSideVC? {
        return self.viewControllerWithID("ScoreboardDappSignFrontSideVC")
    }
    
    internal class func instantiateDappBackSideLinksVC() -> DappBackSideLinksVC? {
        return self.viewControllerWithID("DappBackSideLinksVC")
    }
    
    internal class func instantiateProfileNavigationController() -> UINavigationController? {
        return self.viewControllerWithID("profileNavigationController")
    }
    
    internal class func instantiateDappsNavigationController() -> UINavigationController? {
        return self.viewControllerWithID("dappsNavigationController")
    }
    
    internal class func instantiateFacebookSharedContentVC() -> SocialVC? {
        return self.viewControllerWithID("SocialVC")
    }
    
    // MARK: - private
    
    private class func viewControllerWithID<T>(viewControllerStoryboardID: String) -> T? {
        let viewController =
        self.storyboard.instantiateViewControllerWithIdentifier(viewControllerStoryboardID) as? T
        
        return viewController
    }
}
