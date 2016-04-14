//
//  MainVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/14/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol TransitionDelegate {
    func transitionFromViewController(viewController: UIViewController)
}

class MainVC: UIViewController {
    private var dailyDappVC: DailyDappVC? = nil
    private var scoreboardVC: ScoreboardVC? = nil
    private var childVC: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initChildViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - initial child view controller
    
    private func initChildViewController() {
        self.dailyDappVC = self.storyboard?.instantiateViewControllerWithIdentifier(
            "dailyDappVC") as? DailyDappVC
        
        self.scoreboardVC = self.storyboard?.instantiateViewControllerWithIdentifier(
            "scoreboardVC") as? ScoreboardVC
        
        if let dailyDappVC = self.dailyDappVC {
            dailyDappVC.transitionDelegate = self
            
            self.addChildViewController(dailyDappVC)
            self.initInitialChildViewControllerWith(dailyDappVC)
        }
        
        if let scoreboardVC = self.scoreboardVC {
            scoreboardVC.transitionDelegate = self
            
            self.addChildViewController(scoreboardVC)
        }
    }
    
    // MARK: - 
    
    private func initInitialChildViewControllerWith(childVC: UIViewController) {
        self.view.addSubview(childVC.view)
        
        self.childVC = childVC
    }
    
    // MARK: - transitions
    
    private func transitionToDailyDappVC() {
        if let dailyDappVC = self.dailyDappVC, scoreboardVC = self.scoreboardVC {
            if childVC == scoreboardVC {
                self.transitionFromViewController(scoreboardVC, toViewController: dailyDappVC)
            }
        }
    }
    
    private func transitionToScoreboardVC() {
        if let dailyDappVC = self.dailyDappVC, scoreboardVC = self.scoreboardVC {
            if childVC == dailyDappVC {
                self.transitionFromViewController(dailyDappVC, toViewController: scoreboardVC)
            }
        }
    }
    
    private func transitionFromViewController(
        fromViewController: UIViewController,
        toViewController: UIViewController
    ) {
        self.transitionFromViewController(fromViewController,
            toViewController: toViewController,
            duration: 1.0,
            options: UIViewAnimationOptions.TransitionFlipFromRight,
            animations: nil,
            completion: {
                (finished: Bool) -> Void in
                toViewController.didMoveToParentViewController(self)
                self.childVC = toViewController
        })
    }
}

extension MainVC: TransitionDelegate {
    func transitionFromViewController(viewController: UIViewController) {
        if let dailyDappVC = self.dailyDappVC, scoreboardVC = self.scoreboardVC {
            if viewController == dailyDappVC {
                self.transitionToScoreboardVC()
            } else if viewController == scoreboardVC {
                self.transitionToDailyDappVC()
            }
        }
    }
}
