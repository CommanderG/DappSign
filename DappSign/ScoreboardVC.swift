//
//  ScoreboardVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/29/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ScoreboardVC: UIViewController {
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var composeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBordersToView(self.profileView)
        self.addBordersToView(self.composeView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    
    private func addBordersToView(view: UIView) {
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 6.0
    }
}
