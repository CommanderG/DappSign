//
//  ZipCodeViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ZipCodeViewController: UIViewController {
    @IBOutlet weak var nextButton:                   UIButton!
    @IBOutlet weak var zipCodeTextField:             UITextField!
    @IBOutlet weak var representativeContrainerView: UIView!
    @IBOutlet weak var representativeImageView:      UIImageView!
    @IBOutlet weak var districtLabel:                UILabel!
    @IBOutlet weak var representativeFullNameLabel:  UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.hidden = true
        self.representativeContrainerView.hidden = true
        
        let representativeImageViewWidth = CGRectGetWidth(self.representativeImageView.frame)
        let cornerRadius = representativeImageViewWidth / 2
        
        self.representativeImageView.layer.cornerRadius = cornerRadius
        self.representativeImageView.layer.borderWidth = 2.0
        self.representativeImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.representativeImageView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func downloadRepresentative(sender: AnyObject) {
        self.performSegueWithIdentifier("showHomeViewController", sender: self)
    }
    
    private func requestForDownloadingRepresentativeWithZipCode(zipCode: String) -> NSURLRequest? {
        let URLString = "http://congress.api.sunlightfoundation.com/legislators/locate?" +
                        "zip=\(zipCode)&apikey=a01b4a2e39e044d78d8e5cd18e78fefb"
        
        if let URL = NSURL(string: URLString) {
            let request = NSURLRequest(URL: URL)
            
            return request
        }
        
        return nil
    }
    
    private func downloadRepresentativesWithZipCode(
        zipCode: String,
        completion: (representatives: [NSDictionary]?
    ) -> Void) {
        if let request = self.requestForDownloadingRepresentativeWithZipCode(zipCode) {
            let queue = NSOperationQueue.mainQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let json = try? NSJSONSerialization.JSONObjectWithData(data,
                        options: .MutableContainers
                    )
                    
                    if let json = json, resultCount = json["count"] as? Int {
                        if resultCount <= 0 {
                            completion(representatives: nil)
                        } else if let representatives = json["results"] as? [NSDictionary] {
                            completion(representatives: representatives)
                        } else {
                            completion(representatives: nil)
                        }
                    }
                }
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func saveCongressionalDistrictID(congressionalDistrictID: Int,
        completion: (success: Bool) -> Void
    ) {
        let user = PFUser.currentUser()
        
        user["congressionalDistrictID"] = "\(congressionalDistrictID)"
        
        user.saveInBackgroundWithBlock({
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                print(
                    "Successfully set value of 'congressionalDistrictID' to " +
                    "\(congressionalDistrictID) for user with ID \(user.objectId)"
                )
            } else {
                print(
                    "Failed to set value of 'congressialDistrictID' to "           +
                    "\(congressionalDistrictID) for user with ID \(user.objectId). " +
                    "Error = \(error.localizedDescription)"
                )
            }
            
            completion(success: success)
        })
    }
    
    private func congressialDistrictIDFromResponseData(data: NSData) -> String? {
        let result = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        
        if let
            result                = result,
            statesAndDistricts    = result["results"] as? [NSDictionary],
            firstStateAndDistrict = statesAndDistricts.first,
            state                 = firstStateAndDistrict["state"] as? String,
            district              = firstStateAndDistrict["district"] as? Int {
                let districtString = self.distringStringWithInt(district)
                let congressialDistrictID = "\(state)-\(districtString)"
                
                return congressialDistrictID
        }
        
        return nil
    }
    
    private func distringStringWithInt(district: Int) -> String {
        if district >= 10 {
            return "\(district)"
        }
        
        return "0\(district)"
    }
    
    private func initHouseRepresentativeViews(houseRepresentative: NSDictionary) {
        if let congressionalDistrictID = houseRepresentative["district"] as? Int {
            self.districtLabel.text = "Your \(congressionalDistrictID) rep"
        } else {
            self.districtLabel.text = "Your ??-?? rep"
        }
        
        if let
            firstName = houseRepresentative["first_name"] as? String,
            lastName = houseRepresentative["last_name"] as? String {
                let fullName = "\(firstName) \(lastName)"
                
                self.representativeFullNameLabel.text = fullName
        } else {
            self.representativeFullNameLabel.text = ""
        }
        
        if let bioGuideID = houseRepresentative["bioguide_id"] as? String {
            let URLString = "https://theunitedstates.io/images/congress/original/\(bioGuideID).jpg"
            
            if let URL = NSURL(string: URLString) {
                self.representativeImageView.sd_setImageWithURL(URL)
            }
        }
    }
    
    private func houseRepresentative(representatives: [NSDictionary]) -> NSDictionary? {
        for representative in representatives {
            if let chamber = representative["chamber"] as? String {
                if chamber == "house" {
                    return representative
                }
            }
        }
        
        return nil
    }
}

extension ZipCodeViewController: UITextFieldDelegate {
    func textField(
        textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String
    ) -> Bool {
        self.nextButton.hidden = true
        self.representativeContrainerView.hidden = true
        
        if let text = textField.text as NSString? {
            let zipCode = text.stringByReplacingCharactersInRange(range,
                withString: string
            )
            
            let zipCodeLength = 5
            
            if zipCode.characters.count != zipCodeLength {
                return true
            }
            
            self.downloadRepresentativesWithZipCode(zipCode, completion: {
                (representatives: [NSDictionary]?) -> Void in
                if let
                    representatives = representatives,
                    houseRepresentative = self.houseRepresentative(representatives),
                    congressionalDistrictID = houseRepresentative["district"] as? Int {
                        self.saveCongressionalDistrictID(congressionalDistrictID, completion: {
                            (success: Bool) -> Void in
                            if success {
                                self.nextButton.hidden = false
                                self.representativeContrainerView.hidden = false
                                
                                self.initHouseRepresentativeViews(houseRepresentative)
                            } else {
                                self.nextButton.hidden = true
                                self.representativeContrainerView.hidden = true
                            }
                    })
                }
            })
        }
        
        return true
    }
}
