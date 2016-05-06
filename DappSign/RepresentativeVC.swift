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
    
    internal static let embedSegueID = "embedRepresentativeVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        ViewHelper.initRepresentativeImageViewLayer(self.imageView)
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
                
                self.initFullNameLabelWithRepresentative(representative)
                self.initDistrictLabelWithRepresentative(representative)
                self.initImageViewWithRepresentative(representative)
            })
        }
    }
    
    // MARK: - private
    
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
