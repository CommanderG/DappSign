//
//  ProfileViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var publicPrivateLabel: UILabel!
    @IBOutlet weak var numDappsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    //design
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    var user = PFUser.currentUser()
    var userid:String!
    
    
    var submittedDappData: NSMutableArray! = NSMutableArray()
    //var dappedDappData:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userid = user.objectId
        self.loadData()
    
        
        //var user = PFUser.currentUser()
        
        let image = UIImage(data: user["image"] as NSData)
        
        let name:String = user.objectForKey("name") as String
        

        profilePic.image = image
        
        nameLabel.text = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //DataSource functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DappCell = tableView.dequeueReusableCellWithIdentifier("dappCell") as DappCell
        
        if submittedDappData.count > 0 {
            var dappBackgroundColorString = submittedDappData[indexPath.row].objectForKey("dappBackgroundColor") as String
            var dappStatementString = submittedDappData[indexPath.row].objectForKey("dappStatement") as String
            var dappFontString = submittedDappData[indexPath.row].objectForKey("dappFont") as String
            var dappScore = submittedDappData[indexPath.row].objectForKey("dappScore") as Int
            
            
            cell.dappCellTextView.backgroundColor = dappColors.dappColorWheel[dappBackgroundColorString]
            cell.dappCellTextView.text = dappStatementString
            cell.dappCellTextView.font = dappFonts.dappFontBook[dappFontString]
            
            cell.dappsNumberLabel.text = String(dappScore)
            
        }
        
        
        
        return cell

    }
    
    
    //Delegate function
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    func loadData(){
        var findDappDeckData:PFQuery = PFQuery(className: "Dapps")
        findDappDeckData.whereKey("userid", equalTo: self.userid)
        
        findDappDeckData.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if error == nil{
                println("success \(objects.count)")
                for object in objects{
                    println(object.objectId)
                    //var dapp:PFObject = object as PFObject
                    self.submittedDappData.addObject(object)
                    println(self.submittedDappData.count)
                }
            }
            
            //println("num of dapps: \(self.submittedDappData.count)")
        }
        
        
        
        
    }


    

}
