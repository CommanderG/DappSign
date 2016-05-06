//
//  ScoreboardRepresentativeVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/20/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ScoreboardRepresentativeVC: UIViewController {
    @IBOutlet weak var representativeImageView: UIImageView!
    @IBOutlet weak var districtLabel:           UILabel!
    @IBOutlet weak var representativeNameLabel: UILabel!
    @IBOutlet weak var districtDappScoreLabel:  UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        ViewHelper.initRepresentativeImageViewLayer(self.representativeImageView)
        self.initViewsWithRepresentative(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = PFUser.currentUser() {
            Requests.downloadRepresentativesForUserWithID(user.objectId, completion: {
                (representatives: [PFObject]?, error: NSError?) -> Void in
                let representative = representatives?.first
                
                self.initViewsWithRepresentative(representative)
            })
        }
    }
    
    // MARK: -
    
    private func initViewsWithRepresentative(representative: PFObject?) {
        self.initRepresentativeImageViewWithRepresentative(representative)
        self.initDistrictLabelWithRepresentative(representative)
        self.initRepresentativeNameLabelWithRepresentative(representative)
        self.initDistrictDappScoreLabelWithRepresentative(representative)
    }
    
    private func initRepresentativeImageViewWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            imageURL = RepresentativeHelper.imageURLForRepresentative(representative) {
                self.representativeImageView.sd_setImageWithURL(imageURL)
        } else {
            self.representativeImageView.image = nil
        }
    }
    
    private func initDistrictLabelWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            district = RepresentativeHelper.districtForRepresentative(representative) {
                self.districtLabel.text = "Your \(district) rep"
        } else {
            self.districtLabel.text = ""
        }
    }
    
    private func initRepresentativeNameLabelWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            fullName = RepresentativeHelper.fullNameForRepresentative(representative) {
                self.representativeNameLabel.text = fullName
        } else {
            self.representativeNameLabel.text = ""
        }
    }
    
    private func initDistrictDappScoreLabelWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            district = RepresentativeHelper.districtForRepresentative(representative) {
                DistrictHelper.calculateDappScoreForDistrict(district, completion: {
                    (dappScore: Int?, error: NSError?) -> Void in
                    if let dappScore = dappScore {
                        self.districtDappScoreLabel.text = "\(dappScore)"
                    }
                })
        } else {
            self.districtDappScoreLabel.text = "0"
        }
    }
}
