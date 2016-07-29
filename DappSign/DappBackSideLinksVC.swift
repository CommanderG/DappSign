//
//  DappBackSideLinksVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/13/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol DappBackSideLinksVCDelegate {
    func openLinkWithURL(linkURL: NSURL)
}

class DappBackSideLinksVC: UIViewController {
    internal var delegate: DappBackSideLinksVCDelegate? = nil
    
    private var dappLinksVC: DappLinksVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func showLinksForDapp(dapp: PFObject) {
        self.dappLinksVC?.tableViewTopLC.constant = 0.0
        self.dappLinksVC?.tableViewBottomLC.constant = 0.0
        
        if let colorName = DappHelper.getColorName(dapp) {
            self.view.backgroundColor = DappColors.colorWithColorName(colorName)
        }
        
        self.dappLinksVC?.initWithMode(.Read, andLinks: [])
        
        Requests.downloadLinksForDapp(dapp, completion: {
            (linkObjs: [PFObject]?, error: NSError?) -> Void in
            if let linkObjs = linkObjs {
                let links = self.linksWithLinkObjs(linkObjs)
                
                self.dappLinksVC?.initWithMode(.Read, andLinks: links)
            } else if let error = error {
                print("Error downloading links for dapp with ID \(dapp.objectId): \(error)")
            }
        })
    }
    
    internal func showLinks(links: [Link]) {
        self.view.backgroundColor = UIColor.orangeColor()
        
        self.dappLinksVC?.initWithMode(.Read, andLinks: links)
    }
    
    internal func setBackgroundColor(backgroundColor: UIColor) {
        self.view.backgroundColor = backgroundColor
        self.dappLinksVC?.view.backgroundColor = backgroundColor
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "embedDappLinksVC":
                self.dappLinksVC = segue.destinationViewController as? DappLinksVC
                
                self.dappLinksVC?.delegate = self
                self.dappLinksVC?.view.backgroundColor = UIColor.clearColor()
            case _:
                break
            }
        }
    }
    
    // MARK: -
    
    private func linksWithLinkObjs(linkObjs: [PFObject]) -> [Link] {
        let links = linkObjs.map({
            linkObj -> Link in
            let link = Link(linkObj: linkObj)
            
            return link
        })
        
        return links
    }
}

extension DappBackSideLinksVC: DappLinksVCDelegate {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void) {}
    
    func deleteLink(linkToDelete: Link, completion: (success: Bool, error: NSError?) -> Void) {}
    
    func openLinkURL(linkURL: NSURL) {
        self.delegate?.openLinkWithURL(linkURL)
    }
}
