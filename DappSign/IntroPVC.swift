//
//  IntroPVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/28/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class IntroPVC: UIPageViewController {
    private var introViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LocalStorage.appHasBeenLaunchedBefore() {
            LocalStorage.saveAppHasBeenLaunchedBefore(true)
            
            if let firstIntroPageVC = StoryboardHelper.instantiateFirstIntroVC() {
                self.introViewControllers.append(firstIntroPageVC)
            }
            
            if let secondIntroPageVC = StoryboardHelper.instantiateSecondIntroVC() {
                self.introViewControllers.append(secondIntroPageVC)
            }
            
            if let thirdIntroPageVC = StoryboardHelper.instantiateThirdIntroVC() {
                self.introViewControllers.append(thirdIntroPageVC)
            }
            
            if let fourthIntroPageVC = StoryboardHelper.instantiateFourthIntroVC() {
                self.introViewControllers.append(fourthIntroPageVC)
            }
            
            for viewController in self.introViewControllers {
                viewController.view.backgroundColor = Colors.getViewControllerBackgroundColor()
            }
        }
        
        if let loginVC = StoryboardHelper.instantiateLoginVC() {
            self.introViewControllers.append(loginVC)
        }
        
        self.dataSource = self
        self.delegate = self
        
        if let firstIntroVC = self.introViewControllers.first {
            self.setViewControllers(
                [ firstIntroVC ],
                direction: .Forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension IntroPVC: UIPageViewControllerDataSource {
    internal func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController
    ) -> UIViewController? {
        guard let index = self.introViewControllers.indexOf(viewController) else {
            return nil
        }
        
        if viewController == self.introViewControllers.first {
            return nil
        }
        
        let previousVC = self.introViewControllers[index - 1]
        
        return previousVC
    }
    
    internal func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController
    ) -> UIViewController? {
        guard let index = self.introViewControllers.indexOf(viewController) else {
            return nil
        }
        
        if viewController == self.introViewControllers.last {
            return nil
        }
        
        let nextVC = self.introViewControllers[index + 1]
        
        return nextVC
    }
    
    internal func presentationCountForPageViewController(
        pageViewController: UIPageViewController
    ) -> Int {
        return self.introViewControllers.count
    }
    
    internal func presentationIndexForPageViewController(
        pageViewController: UIPageViewController
    ) -> Int {
        if self.introViewControllers.count == 1 {
            return -1
        }
        
        return 0
    }
}

extension IntroPVC: UIPageViewControllerDelegate {
    internal func pageViewController(
        pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        print(previousViewControllers)
    }
}
