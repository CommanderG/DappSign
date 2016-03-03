//
//  RepresentativesViewController.swift
//  DappSign
//
//  Created by imandet on 06/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class RepresentativesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var arrRepresentativeData: NSMutableArray = NSMutableArray()
    var userID = ""
    var arrRepresentativeDataRep = NSMutableArray ()
    var arrRepresentativeDataSen = NSMutableArray ()
    
    @IBOutlet var tblView: UITableView!
    
    @IBAction func onBtnHomeView(sender: AnyObject) {
        self.performSegueWithIdentifier("showHomeViewController", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.backgroundColor = UIColor.clearColor()
        tblView.backgroundView = nil
        
        saveDataToParse()
        
        arrRepresentativeData = NSMutableArray ()
        arrRepresentativeData.addObjectsFromArray(arrRepresentativeDataSen as [AnyObject])
        arrRepresentativeData.addObjectsFromArray(arrRepresentativeDataRep as [AnyObject])
        
        tblView.reloadData()
    }
    
    func saveDataToParse() {
        for representativeData in self.arrRepresentativeData {
            if let
                representativeData = representativeData as? NSDictionary,
                strFName           = representativeData["first_name"] as? String,
                strLName           = representativeData["last_name"] as? String,
                strTitle           = representativeData["title"] as? String,
                strParty           = representativeData["party"] as? String,
                ID                 = representativeData["bioguide_id"] as? String {
                    if strTitle == "Sen" {
                        arrRepresentativeDataSen.addObject(representativeData)
                    } else {
                        arrRepresentativeDataRep.addObject(representativeData)
                    }
                    
                    let strImgUrl = "https://theunitedstates.io/images/congress/original/\(ID).jpg"
                    let strFullName =  "\(strFName) \(strLName)"
                    
                    Requests.addRepresentative(userID,
                        imgUrl:   strImgUrl,
                        strName:  strFullName,
                        strTitle: strTitle,
                        strParty: strParty
                    )
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRepresentativeData.count
    }
    
    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "repreCell",
            forIndexPath: indexPath
        ) as! CustomCell
        if let representativeData = arrRepresentativeData[indexPath.row] as? NSDictionary {
            if let
                strFName = representativeData["first_name"] as? String,
                strLName = representativeData["last_name"] as? String,
        		strTitle = representativeData["title"] as? String,
            	strParty = representativeData["party"] as? String {
                    let strFullName = "\(strFName) \(strLName)"
                    
                    cell.setCell(strFullName, strTitle: strTitle, strParty: strParty)
            }
            
            if let ID = representativeData["bioguide_id"] as? String {
                let strImgUrl = "https://theunitedstates.io/images/congress/original/\(ID).jpg"
                let url = NSURL(string: strImgUrl)
                
                cell.imgView.sd_setImageWithURL(url, completed: {
                    (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                })
            }
        }
        
        cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2
        cell.imgView.clipsToBounds = true
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.clearColor()
        
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
