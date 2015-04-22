//
//  RepresentativesViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class RepresentativesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var arrRepresentativeData = NSMutableArray ()
    var userID : String = ""
    var arrRepresentativeDataRep = NSMutableArray ()
    var arrRepresentativeDataSen = NSMutableArray ()

    @IBOutlet var tblView: UITableView!
   
    @IBAction func onBtnHomeView(sender: AnyObject) {
    
        self.performSegueWithIdentifier("showHomeViewController", sender: self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tblView.backgroundColor=UIColor.clearColor()
        tblView.backgroundView=nil

        SaveDataToPArse()
        
        arrRepresentativeData = NSMutableArray ()
        arrRepresentativeData.addObjectsFromArray(arrRepresentativeDataSen as [AnyObject])
        arrRepresentativeData.addObjectsFromArray(arrRepresentativeDataRep as [AnyObject])

        tblView.reloadData()
    }
    
    

    func SaveDataToPArse(){
        
        for var i = 0; i < 3; i++
        {
            var ObjectValue: NSDictionary = arrRepresentativeData[i] as! NSDictionary
            let strFName : String = ObjectValue.valueForKey("first_name")! as! String
            let strLName : String = ObjectValue.valueForKey("last_name")! as! String
            var strFullName : String =  "\(strFName) \(strLName)"
            
            var strTitle : String = ObjectValue.valueForKey("title")! as! String
            var strParty : String = ObjectValue.valueForKey("party")! as! String
            
            let strUrl1 : String = "https://theunitedstates.io/images/congress/original/"
            let strUrl2 : String = ObjectValue.valueForKey("bioguide_id")! as! String
            let strUrl3 : String = ".jpg"
            
            if strTitle == "Sen" {
                arrRepresentativeDataSen.addObject(ObjectValue)
            }else{
                arrRepresentativeDataRep.addObject(ObjectValue)
            }

            var strImgUrl : String = strUrl1+strUrl2+strUrl3

            Requests.addRepresentative(userID, imgUrl: strImgUrl, strName: strFullName, strTitle: strTitle, strParty: strParty)
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRepresentativeData.count
    }


     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let cell : CustomCell = tableView.dequeueReusableCellWithIdentifier("repreCell", forIndexPath: indexPath)
                as! CustomCell
            
            var ObjectValue: NSDictionary = arrRepresentativeData[indexPath.row] as! NSDictionary
           
            
            let strFName : String = ObjectValue.valueForKey("first_name")! as! String
            let strLName : String = ObjectValue.valueForKey("last_name")! as! String
            var strFullName : String =  "\(strFName) \(strLName)"
            
            var strTitle : String = ObjectValue.valueForKey("title")! as! String
            var strParty : String = ObjectValue.valueForKey("party")! as! String

            cell.setCell(strFullName, strTitle: strTitle, strParty: strParty)
            
            let strUrl1 : String = "https://theunitedstates.io/images/congress/original/"
            let strUrl2 : String = ObjectValue.valueForKey("bioguide_id")! as! String
            let strUrl3 : String = ".jpg"
            
            var strImgUrl : String = strUrl1+strUrl2+strUrl3
            
            let url = NSURL(string: strImgUrl)
            
            cell.imgView.sd_setImageWithURL(url, completed: {
                (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
            })
            cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width/2
            cell.imgView.clipsToBounds = true
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor=UIColor.clearColor()
            
          return cell
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


}
