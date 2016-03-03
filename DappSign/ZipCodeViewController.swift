//
//  ZipCodeViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ZipCodeViewController: UIViewController {
    @IBOutlet var zipCodeTextField: UITextField!
    
    private var representatives: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func downloadRepresentative(sender: AnyObject) {
        if let zipCode = self.zipCodeTextField.text {
            if zipCode.isEmpty {
                self.showAlertViewWithOKButtonAndMessage("Please enter your zip code.")
            } else {
                self.downloadRepresentativesWithZipCode(zipCode, completion: {
                    (representatives: [NSDictionary]?) -> Void in
                    if let representatives = representatives {
                        self.representatives = representatives
                        
                        self.downloadAndSetUserCongressionalDistrictIDForZipCode(zipCode)
                        self.performSegueWithIdentifier("Representative", sender: self)
                    }
                })
            }
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
                            self.showAlertViewWithOKButtonAndMessage(
                                "No results found. Please try again."
                            )
                            
                            completion(representatives: nil)
                        } else if let representatives = json["results"] as? [NSDictionary] {
                            completion(representatives: representatives)
                        } else {
                            completion(representatives: nil)
                        }
                    }
                } else {
                    self.showAlertViewWithOKButtonAndMessage(
                        "An error occured. Please try again later."
                    )
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let representativeVC = segue.destinationViewController as? RepresentativesViewController
        
        representativeVC?.arrRepresentativeData = NSMutableArray(array: self.representatives)
        representativeVC?.userID = PFUser.currentUser().objectId
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func downloadAndSetUserCongressionalDistrictIDForZipCode(zipCode: String) {
        Requests.downloadCongressialDistrictsForZipCode(zipCode, completion: {
            (data: NSData!, error: NSError!) -> Void in
            if let err = error {
                print("\(err.localizedDescription)")
                
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
                })
            }
        })
    }
    
    private func congressialDistrictIDFromResponseData(data: NSData) -> String? {
        let result = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        
        if let
            res                   = result,
            statesAndDistricts    = res["results"] as? [NSDictionary],
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
}
