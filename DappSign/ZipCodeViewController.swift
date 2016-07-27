//
//  ZipCodeViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

protocol ZipCodeDelegate {
    func didSaveRepresentativeAndDistrictInformation(success: Bool)
}

class ZipCodeViewController: UIViewController {
    @IBOutlet weak var nextButton:                   UIButton!
    @IBOutlet weak var zipCodeTextField:             UITextField!
    @IBOutlet weak var representativeContrainerView: UIView!
    @IBOutlet weak var representativeImageView:      UIImageView!
    @IBOutlet weak var districtLabel:                UILabel!
    @IBOutlet weak var representativeFullNameLabel:  UILabel!
    
    internal var delegate: ZipCodeDelegate? = nil
    
    private var houseRepresentative: NSDictionary? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        
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
    
    @IBAction func goToHomeViewController(sender: AnyObject) {
        if let
            houseRepresentative = self.houseRepresentative,
            congressionalDistrictID = self.congressionalDistrictID(houseRepresentative) {
                ViewHelper.disableButtons([ self.nextButton ])
                self.saveCongressionalDistrictID(congressionalDistrictID, completion: {
                    (success: Bool) -> Void in
                    if !success {
                        ViewHelper.enableButtons([ self.nextButton ])
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.delegate?.didSaveRepresentativeAndDistrictInformation(false)
                        
                        return
                    }
                    
                    self.saveHouseRepresentativeOnParse(houseRepresentative, completion: {
                        (success: Bool) -> Void in
                        ViewHelper.enableButtons([ self.nextButton ])
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.delegate?.didSaveRepresentativeAndDistrictInformation(success)
                    })
                })
        }
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
    
    private func saveCongressionalDistrictID(congressionalDistrictID: String,
        completion: (success: Bool) -> Void
    ) {
        let user = PFUser.currentUser()
        
        user["congressionalDistrictID"] = congressionalDistrictID
        
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
    
    private func congressionalDistrictID(houseRepresentative: NSDictionary) -> String? {
        if let
            state = houseRepresentative["state"] as? String,
            district = houseRepresentative["district"] as? Int {
                let districtString = self.distringStringWithInt(district)
                let congressionalDistrictID = "\(state)-\(districtString)"
                
                return congressionalDistrictID
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
        if let congressionalDistrictID = self.congressionalDistrictID(houseRepresentative) {
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
        
        if let
            URLString = self.representativeImageURLString(houseRepresentative),
            URL = NSURL(string: URLString) {
                self.representativeImageView.sd_setImageWithURL(URL)
        }
    }
    
    private func representativeImageURLString(representative: NSDictionary) -> String? {
        if let bioGuideID = representative["bioguide_id"] as? String {
            let URLString = "https://theunitedstates.io/images/congress/original/\(bioGuideID).jpg"
            
            return URLString
        }
        
        return nil
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
    
    private func saveHouseRepresentativeOnParse(houseRepresentative: NSDictionary,
        completion: (success: Bool) -> Void
    ) {
        if let
            imageURLString = self.representativeImageURLString(houseRepresentative),
            firstName      = houseRepresentative["first_name"] as? String,
            lastName       = houseRepresentative["last_name"] as? String,
            title          = houseRepresentative["title"] as? String,
            party          = houseRepresentative["party"] as? String,
            district       = self.congressionalDistrictID(houseRepresentative),
            user           = PFUser.currentUser() {
                let userID = user.objectId
                
                self.deleteRepresentativesWithUserID(userID) {
                    let fullName =  "\(firstName) \(lastName)"
                    let facebookID = self.facebookID(houseRepresentative)
                    let twitterID = self.twitterID(houseRepresentative)
                    
                    Requests.addRepresentativeWithUserID(userID,
                        imageURLString: imageURLString,
                        fullName: fullName,
                        title: title,
                        party: party,
                        district: district,
                        facebookID: facebookID,
                        twitterID: twitterID,
                        completion: {
                            (success: Bool, error: NSError?) -> Void in
                            completion(success: success)
                    })
                }
        }
    }
    
    private func deleteRepresentativesWithUserID(userID: String, completion: Void -> Void) {
        Requests.downloadRepresentativesForUserWithID(userID) {
            (representatives: [PFObject]?, error: NSError?) -> Void in
            if let representatives = representatives {
                PFObject.deleteAllInBackground(representatives, block: {
                    (success: Bool, error: NSError?) -> Void in
                    completion()
                })
            } else {
                completion()
            }
        }
    }
    
    private func twitterID(houseRepresentative: NSDictionary) -> String {
        if let twitterID = houseRepresentative["twitter_id"] as? String {
            return twitterID
        }
        
        return ""
    }
    
    private func facebookID(houseRepresentative: NSDictionary) -> String {
        if let facebookID = houseRepresentative["facebook_id"] as? String {
            return facebookID
        }
        
        return ""
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
                    houseRepresentative = self.houseRepresentative(representatives) {
                        self.houseRepresentative = houseRepresentative
                        
                        self.nextButton.hidden = false
                        self.representativeContrainerView.hidden = false
                        
                        self.initHouseRepresentativeViews(houseRepresentative)
                } else {
                    self.houseRepresentative = nil
                    
                    self.nextButton.hidden = true
                    self.representativeContrainerView.hidden = true
                }
            })
        }
        
        return true
    }
}
