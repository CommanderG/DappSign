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
        if txtZipCode.text.isEmpty{
            println("Zip code empty!")
        }else{
          //  self.performSegueWithIdentifier("showZipCode", sender: self)
            startConnection()

        }
    }
    
    
    
    func startConnection(){
        let urlPath: String = "http://congress.api.sunlightfoundation.com/legislators/locate?zip=" + txtZipCode.text + "&apikey=a01b4a2e39e044d78d8e5cd18e78fefb"
        var url: NSURL = NSURL(string: urlPath)!
        self.data = NSMutableData()
        
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        // throwing an error on the line below (can't figure out where the error message is)
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        var resultCount = jsonResult["count"] as! NSInteger

        
        if resultCount > 0{
            self.downloadAndSetUserCongressionalDistrictIDForZipCode(txtZipCode.text)
            
            arrSentData = jsonResult["results"] as! NSMutableArray
           //  performSegueWithIdentifier("Representative", sender: nil)
             self.performSegueWithIdentifier("Representative", sender: self)
            
            
        }else{
            
            let alert = UIAlertView()
            alert.title = "Info"
            alert.message = "No result found! Please try again!"
            alert.addButtonWithTitle("Ok")
            alert.show()
            println("zero result found")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var RepresentativeVC : RepresentativesViewController = segue.destinationViewController as! RepresentativesViewController
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
                println("\(err.localizedDescription)")
                
                return
            }
            
            if let congressialDistrictID = self.getCongressialDistrictIDFromResponseData(data) {
                let user = PFUser.currentUser()
                
                user["congressionalDistrictID"] = congressialDistrictID
                
                user.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError!) -> Void in
                    if (success) {
                        println("Successfully set value of 'congressialDistrictID' to \(congressialDistrictID) for user with ID \(user.objectId)")
                    } else {
                        println("Failed to set value of 'congressialDistrictID' to \(congressialDistrictID) for user with ID \(user.objectId). Error = \(error.localizedDescription)")
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
        
        var serializationError: NSError?
        let result = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.MutableContainers,
            error: &serializationError) as? NSDictionary
        
        if let serErr = serializationError {
            println(serErr.localizedDescription)
            
            return nil
        }
        
        if let
            res                   = result,
            statesAndDistricts    = res["results"] as? [NSDictionary],
            firstStateAndDistrict = statesAndDistricts.first,
            state                 = firstStateAndDistrict["state"] as? String,
            district              = firstStateAndDistrict["district"] as? Int {
                let districtStr = getDistrictStr(district)
                let congressialDistrictID = "\(state)-\(districtStr)"
                
                return congressialDistrictID
        }
        
        return nil
    }
}
