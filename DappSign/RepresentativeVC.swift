//
//  RepresentativeVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol RepresentativeDelegate {
    func didDownloadNewRepresentativeData(newData: Bool)
}

class RepresentativeVC: UIViewController {
    @IBOutlet weak var imageView:     UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    
    private var fullName = ""
    private var district = ""
    private var imageURLString = ""
    
    private(set) internal var downloaded = false
    
    internal var delegate: RepresentativeDelegate? = nil
    
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
                
                let newFullName = self.getFullName(representative)
                let newDistrict = self.getDistrict(representative)
                let newImageURLString = self.getImageURLString(representative)
                
                if (self.fullName != newFullName ||
                    self.district != newDistrict ||
                    self.imageURLString != newImageURLString) {
                        self.fullName = newFullName
                        self.district = newDistrict
                        self.imageURLString = newImageURLString
                        
                        self.fullNameLabel.text = self.fullName
                        self.districtLabel.text = self.district
                        
                        if let imageURL = NSURL(string: self.imageURLString) {
                            self.imageView.sd_setImageWithURL(imageURL)
                        }
                        
                        self.delegate?.didDownloadNewRepresentativeData(true)
                } else {
                    self.delegate?.didDownloadNewRepresentativeData(false)
                }
                
                self.downloaded = true
            })
        }
    }
    
    // MARK: - private
    
    private func getFullName(representative: PFObject?) -> String {
        if let
            representative = representative,
            fullName = RepresentativeHelper.fullNameForRepresentative(representative) {
                return fullName
        }
        
        return ""
    }
    
    private func getDistrict(representative: PFObject?) -> String {
        if let
            representative = representative,
            district = RepresentativeHelper.districtForRepresentative(representative) {
                return district
        }
        
        return ""
    }
    
    private func getImageURLString(representative: PFObject?) -> String {
        if let
            representative = representative,
            imageURL = RepresentativeHelper.imageURLForRepresentative(representative) {
                return imageURL.absoluteString
        }
        
        return ""
    }
}
