//
//  RepresentativeVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class RepresentativeVC: UIViewController {
    @IBOutlet weak var imageView:     UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initImageViewLayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    
    internal func reload() {
        if let user = PFUser.currentUser() {
            Requests.downloadRepresentativesForUserWithID(user.objectId, completion: {
                (representatives: [PFObject]?, error: NSError?) -> Void in
                let representative = representatives?.first
                
                self.initFullNameLabelWithRepresentative(representative)
                self.initDistrictLabelWithRepresentative(representative)
                self.initImageViewWithRepresentative(representative)
            })
        }
    }
    
    // MARK: - private
    
    private func initImageViewLayer() {
        let cornerRadius = CGRectGetWidth(self.imageView.frame) / 2
        
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageView.layer.borderWidth = 2.0
        self.imageView.layer.cornerRadius = cornerRadius
    }
    
    private func initFullNameLabelWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            fullName = RepresentativeHelper.fullNameForRepresentative(representative) {
                self.fullNameLabel.text = fullName
        } else {
            self.fullNameLabel.text = ""
        }
    }
    
    private func initDistrictLabelWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            district = RepresentativeHelper.districtForRepresentative(representative) {
                self.districtLabel.text = district
        } else {
            self.districtLabel.text = ""
        }
    }
    
    private func initImageViewWithRepresentative(representative: PFObject?) {
        if let
            representative = representative,
            imageURL = RepresentativeHelper.imageURLForRepresentative(representative) {
                self.imageView.sd_setImageWithURL(imageURL)
        } else {
            self.imageView.image = nil
        }
    }
}
