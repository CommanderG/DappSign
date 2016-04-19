//
//  ScoreboardDappSignFrontSideVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol ScoreboardDappSignCountdownDelegate {
    func didFinishCountingDown()
}

class ScoreboardDappSignFrontSideVC: UIViewController {
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var dappSubmitterLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    internal static let embedSegueID: String = "embedScoreboardDappSignFrontSideVC"
    
    internal var countdownDelegate: ScoreboardDappSignCountdownDelegate? = nil
    
    private let maxSeconds = 10
    
    private var countdownTimer: NSTimer? = nil
    private var secondsLeft = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DappSignViewsHelper.initViewLayer(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - internal
    
    internal func showDappObject(dapp: PFObject?) {
        DappSignViewsHelper.showDappObject(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            view: self.view
        )
        self.secondsLeft = self.maxSeconds
        
        self.countdownTimer?.invalidate()
        
        self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: "countDown",
            userInfo: nil,
            repeats:  true
        )
        
        self.countdownTimer?.fire()
        AnimationHelper.animateDappSignView(self.view)
    }
    
    // MARK: - animation
    
    internal func moveRighOffTheScreen(completion: (Void -> Void)? = nil) {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let animationDuration = 0.5
        
        spring(animationDuration) {
            let translateRightOffTheScreen = CGAffineTransformMakeTranslation(screenWidth, 0.0)
            
            self.view.transform = translateRightOffTheScreen
        }
        
        delay(animationDuration) {
            completion?()
        }
    }
    
    // MARK: - timer functions
    
    internal func countDown() {
        self.secondsLabel.text = "\(self.secondsLeft)"
        
        if self.secondsLeft > 0 {
            --self.secondsLeft
        } else {
            if self.secondsLeft == 0 {
                self.countdownDelegate?.didFinishCountingDown()
            }
            
            self.countdownTimer?.invalidate()
            
            self.countdownTimer = nil
        }
    }
}
