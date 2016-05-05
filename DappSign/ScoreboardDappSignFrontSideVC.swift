//
//  ScoreboardDappSignFrontSideVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol CountdownDelegate {
    func didFinishCountingDown()
}

class ScoreboardDappSignFrontSideVC: UIViewController {
    @IBOutlet weak var dappStatementLabel: UILabel!
    @IBOutlet weak var dappSubmitterLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    internal static let embedSegueID = "embedScoreboardDappSignFrontSideVC"
    
    internal var countdownDelegate: CountdownDelegate? = nil
    
    private let maxSeconds = 10
    
    private var dapp: PFObject? = nil
    private var countdownTimer: NSTimer? = nil
    private var secondsLeft = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DappSignViewsHelper.initViewLayer(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.resumeCountdown()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.pauseCountdown()
    }
    
    // MARK: - internal
    
    internal func showDappObject(dapp: PFObject?) {
        self.dapp = dapp
        
        DappSignViewsHelper.showDappObject(dapp,
            dappStatementLabel: self.dappStatementLabel,
            dappSubmitterLabel: self.dappSubmitterLabel,
            view: self.view
        )
        self.secondsLeft = self.maxSeconds
        self.initAndFireCountdownTimer()
    }
    
    internal func pauseCountdown() {
        self.countdownTimer?.invalidate()
    }
    
    internal func resumeCountdown() {
        if let _ = self.dapp {
            self.initAndFireCountdownTimer()
        }
    }
    
    // MARK: - timer functions
    
    private func initAndFireCountdownTimer() {
        self.countdownTimer?.invalidate()
        
        self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: "countDown",
            userInfo: nil,
            repeats:  true
        )
        
        self.countdownTimer?.fire()
    }
    
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
