//
//  EditDappLinksVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/22/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class EditDappLinksVC: UIViewController {
    private let embedDappLinksVCSegueID = "embedDappLinksVCSegue"
    
    internal var dapp: PFObject?
    
    private var linkTuples: [(PFObject, Link)] = []
    
    private var dappLinksVC: DappLinksVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        
        if let font = UIFont(name: "Exo-Regular", size: 18.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        self.dappLinksVC?.view.userInteractionEnabled = false
        self.dappLinksVC?.view.alpha = 0.5
        
        self.dappLinksVC?.addBorder()
        
        if let dapp = self.dapp {
            Requests.downloadLinksForDapp(dapp, completion: {
                (linkObjs: [PFObject]?, error: NSError?) -> Void in
                self.dappLinksVC?.view.userInteractionEnabled = true
                self.dappLinksVC?.view.alpha = 1.0
                
                if let linkObjs = linkObjs {
                    self.linkTuples = linkObjs.map({
                        linkObj -> (PFObject, Link) in
                        let link = Link(linkObj: linkObj)
                        
                        return (linkObj, link)
                    })
                    
                    let links = self.linkTuples.map({
                        linkTuple -> Link in
                        let (_, link) = linkTuple
                        
                        return link
                    })
                    
                    self.dappLinksVC?.initWithMode(.AddEdit, andLinks: links)
                } else if let error = error {
                    print("Error downloading links for dapp with ID \(dapp.objectId): \(error)")
                }
            })
            
            if let colorName = DappHelper.getColorName(dapp) {
                self.dappLinksVC?.view.backgroundColor = DappColors.colorWithColorName(colorName)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == embedDappLinksVCSegueID {
            self.dappLinksVC = segue.destinationViewController as? DappLinksVC
            self.dappLinksVC?.delegate = self
        }
    }
}

extension EditDappLinksVC: DappLinksVCDelegate {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void) {
        if let dapp = self.dapp {
            Requests.uploadLinks([link]) {
                (linkObjs: [PFObject], error: NSError?) -> Void in
                if let linkObj = linkObjs.first {
                    let dappLinksRelation = dapp.relationForKey("links")
                    
                    dappLinksRelation?.addObject(linkObj)
                    dapp.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError?) -> Void in
                        let link = Link(linkObj: linkObj)
                        let linkTuple = (linkObj, link)
                        
                        self.linkTuples.append(linkTuple)
                        
                        completion(success: success, error: error)
                    })
                } else {
                    completion(success: false, error: error)
                }
            }
        } else {
            completion(success: false, error: nil)
        }
    }
    
    func deleteLink(linkToDelete: Link, completion: (success: Bool, error: NSError?) -> Void) {
        if let dapp = self.dapp {
            for linkTupleIndex in 0 ..< self.linkTuples.count {
                let linkTuple = self.linkTuples[linkTupleIndex]
                let (linkObj, link) = linkTuple
                
                if link == linkToDelete {
                    let dappLinksRelation = dapp.relationForKey("links")
                    
                    dappLinksRelation.removeObject(linkObj)
                    
                    dapp.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError?) -> Void in
                        self.linkTuples.removeAtIndex(linkTupleIndex)
                        
                        completion(success: true, error: nil)
                    })
                }
            }
        } else {
            completion(success: false, error: nil)
        }
    }
    
    func openLinkURL(linkURL: NSURL) {}
}
