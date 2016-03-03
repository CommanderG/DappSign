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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func downloadRepresentative(sender: AnyObject) {
        self.performSegueWithIdentifier("Representative", sender: self)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let representativeVC = segue.destinationViewController as? RepresentativesViewController
//        
//        representativeVC?.arrRepresentativeData = NSMutableArray(array: self.representatives)
//        representativeVC?.userID = PFUser.currentUser().objectId
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func downloadAndSetUserCongressionalDistrictIDForZipCode(zipCode: String,
        completion: (success: Bool, congressionalDistrictID: String?) -> Void
    ) {
        Requests.downloadCongressialDistrictsForZipCode(zipCode, completion: {
            (data: NSData!, error: NSError!) -> Void in
            if let err = error {
                print("\(err.localizedDescription)")
                
                completion(success: false, congressionalDistrictID: nil)
                
                return
            }
            
            if let congressialDistrictID = self.congressialDistrictIDFromResponseData(data) {
                let user = PFUser.currentUser()
                
                user["congressionalDistrictID"] = congressialDistrictID
                
                user.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError!) -> Void in
                    if (success) {
                        print(
                            "Successfully set value of 'congressialDistrictID' to " +
                            "\(congressialDistrictID) for user with ID \(user.objectId)"
                        )
                    } else {
                        print(
                            "Failed to set value of 'congressialDistrictID' to "           +
                            "\(congressialDistrictID) for user with ID \(user.objectId). " +
                            "Error = \(error.localizedDescription)"
                        )
                    }
                    
                    completion(success: success, congressionalDistrictID: congressialDistrictID)
                })
            }
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
    
    private func initRepresentativeViewsWithRepresentatives(representatives: [NSDictionary],
        congressionalDistrictID: String
    ) {
        self.districtLabel.text = "Your \(congressionalDistrictID) rep"
        
        if let houseRepresentative = self.houseRepresentative(representatives) {
            if let
                firstName = houseRepresentative["first_name"] as? String,
                lastName = houseRepresentative["last_name"] as? String {
                    let fullName = "\(firstName) \(lastName)"
                    
                    self.representativeFullNameLabel.text = fullName
            } else {
                self.representativeFullNameLabel.text = ""
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
            
            if zipCode.characters.count == 5 {
                self.downloadRepresentativesWithZipCode(zipCode, completion: {
                    (representatives: [NSDictionary]?) -> Void in
                    if let representatives = representatives {
                        self.downloadAndSetUserCongressionalDistrictIDForZipCode(zipCode,
                            completion: {
                                (success: Bool, congressionalDistrictID: String?) -> Void in
                                if success {
                                    self.nextButton.hidden = false
                                } else {
                                    self.nextButton.hidden = true
                                }
                                
                                if let congressionalDistrictID = congressionalDistrictID {
                                    self.representativeContrainerView.hidden = false
                                    
                                    self.initRepresentativeViewsWithRepresentatives(representatives,
                                        congressionalDistrictID: congressionalDistrictID
                                    )
                                } else {
                                    self.representativeContrainerView.hidden = true
                                }
                        })
                    }
                    
                    print(representatives)
                })
            }
        }
        
        return true
    }
}
