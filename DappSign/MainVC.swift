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
    private var homeVC: HomeViewController? = nil
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
        self.homeVC = self.storyboard?.instantiateViewControllerWithIdentifier(
            "homeVC") as? HomeViewController
        
        self.scoreboardVC = self.storyboard?.instantiateViewControllerWithIdentifier(
            "scoreboardVC") as? ScoreboardVC
        
        if let homeVC = self.homeVC {
            homeVC.transitionDelegate = self
            
            self.addChildViewController(homeVC)
            self.initInitialChildViewControllerWith(homeVC)
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
    
    private func transitionToHomeVC() {
        if let homeVC = self.homeVC, scoreboardVC = self.scoreboardVC, childVC = self.childVC {
            if childVC == scoreboardVC {
                self.transitionFromViewController(scoreboardVC, toViewController: homeVC)
            }
        }
    }
    
    private func transitionToScoreboardVC() {
        if let homeVC = self.homeVC, scoreboardVC = self.scoreboardVC {
            if childVC == homeVC {
                self.transitionFromViewController(homeVC, toViewController: scoreboardVC)
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
        if let homeVC = self.homeVC, scoreboardVC = self.scoreboardVC {
            if viewController == homeVC {
                self.transitionToScoreboardVC()
            } else if viewController == scoreboardVC {
                self.transitionToHomeVC()
            }
        }
    }
}
