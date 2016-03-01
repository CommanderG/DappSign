//
//  ScoreboardVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/29/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ScoreboardVC: UIViewController {
    @IBOutlet weak var profileButton:           UIButton!
    @IBOutlet weak var composeButton:           UIButton!
    @IBOutlet weak var representativeImageView: UIImageView!
    @IBOutlet weak var representativeNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initButtons()
        self.initRepresentativeImageView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    
    private func initButtons() {
        self.addBordersToView(self.profileButton)
        self.addBordersToView(self.composeButton)
        
        let cornerRadius: CGFloat = 6.0
        
        self.profileButton.layer.cornerRadius = cornerRadius
        self.composeButton.layer.cornerRadius = cornerRadius
    }
    
    private func initRepresentativeImageView() {
        self.addBordersToView(self.representativeImageView)
        
        let representativeImageViewWidth = CGRectGetWidth(self.representativeImageView.frame)
        let cornerRadius = representativeImageViewWidth / 2
        
        self.representativeImageView.layer.cornerRadius = cornerRadius
    }
    
    private func addBordersToView(view: UIView) {
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 2.0
    }
}
