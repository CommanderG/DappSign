//
//  ZipCodeViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit


class ZipCodeViewController: UIViewController,NSURLConnectionDelegate {
    
    var data = NSMutableData()
    var arrSentData = NSMutableArray ()
    var strUserID : String = ""
    
    @IBOutlet var txtZipCode: UITextField!
  
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func btnCheckZipCode(sender: AnyObject) {
        if let zipCode = txtZipCode.text {
            if !zipCode.isEmpty {
                //  self.performSegueWithIdentifier("showZipCode", sender: self)
                startConnection()
            } else {
                print("Zip code empty!")
            }
        }
    }
    
    
    
    func startConnection(){
        if let zipCode = txtZipCode.text {
            let urlSubPath1 = "http://congress.api.sunlightfoundation.com/legislators/locate?zip="
            let urlSubPath2 = "&apikey=a01b4a2e39e044d78d8e5cd18e78fefb"
            let urlPath = urlSubPath1 + zipCode + urlSubPath2
            
            if let url = NSURL(string: urlPath) {
                self.data = NSMutableData()
                
                let request = NSURLRequest(URL: url)
                
                if let connection = NSURLConnection(
                    request: request
                ,   delegate: self
                ,   startImmediately: false
                ) {
                    connection.start()
                }
            }
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        
        if let jsonResult = json, resultCount = jsonResult["count"] as! Int? {
            if resultCount > 0 {
                if let  zipCode = txtZipCode.text
                    ,   results = jsonResult["results"] as! NSMutableArray? {
                        self.downloadAndSetUserCongressionalDistrictIDForZipCode(zipCode)
                        
                        arrSentData = results
                        
                        self.performSegueWithIdentifier("Representative", sender: self)
                }
            } else {
                let alert = UIAlertView()
                alert.title = "Info"
                alert.message = "No result found! Please try again!"
                alert.addButtonWithTitle("Ok")
                alert.show()
                print("zero result found")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let RepresentativeVC : RepresentativesViewController = segue.destinationViewController as! RepresentativesViewController
        RepresentativeVC.arrRepresentativeData = arrSentData
        RepresentativeVC.userID = strUserID 
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
            
            if let congressialDistrictID = self.getCongressialDistrictIDFromResponseData(data) {
                let user = PFUser.currentUser()
                
                user["congressionalDistrictID"] = congressialDistrictID
                
                user.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError!) -> Void in
                    if (success) {
                        print("Successfully set value of 'congressialDistrictID' to \(congressialDistrictID) for user with ID \(user.objectId)")
                    } else {
                        print("Failed to set value of 'congressialDistrictID' to \(congressialDistrictID) for user with ID \(user.objectId). Error = \(error.localizedDescription)")
                    }
                })
            }
        })
    }
    
    private func getCongressialDistrictIDFromResponseData(data: NSData!) -> String? {
        func getDistrictStr(district: Int) -> String {
            if district >= 10 {
                return "\(district)"
            }
            
            return "0\(district)"
        }
        
        let result = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        
        if let  res                   = result
            ,   statesAndDistricts    = res["results"] as? [NSDictionary]
            ,   firstStateAndDistrict = statesAndDistricts.first
            ,   state                 = firstStateAndDistrict["state"] as? String
            ,   district              = firstStateAndDistrict["district"] as? Int {
                let districtStr = getDistrictStr(district)
                let congressialDistrictID = "\(state)-\(districtStr)"
                
                return congressialDistrictID
        }
        
        return nil
    }
}
