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
        txtZipCode.text=""
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


}
