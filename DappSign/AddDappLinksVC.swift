//
//  AddDappLinksVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/22/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class AddDappLinksVC: UIViewController {
    @IBOutlet weak var containerView: SwipeableView!
    
    private let embedDappLinksVCSegueID = "embedDappLinksVCSegue"
    private let finalDappSegueID = "finalDappSegue"
    
    private var dappLinkVC: DappLinksVC?
    private var links: [Link] = []
    
    internal var dapp: Dapp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.minTranslationX = 150.0
        self.containerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == embedDappLinksVCSegueID {
            self.dappLinkVC = segue.destinationViewController as? DappLinksVC
            self.dappLinkVC?.delegate = self
        } else if segue.identifier == finalDappSegueID {
            let finalDappSubmitVC = segue.destinationViewController as? FinalDappSubmitViewController
            finalDappSubmitVC?.dapp = self.dapp
            finalDappSubmitVC?.links = self.links
        }
    }
}

extension AddDappLinksVC: DappLinksVCDelegate {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void) {
        self.links.append(link)
        
        completion(success: true, error: nil)
    }
    
    func deleteLinkAtIndex(linkIndex: Int, completion: (success: Bool, error: NSError?) -> Void) {
        if linkIndex < self.links.count {
            self.links.removeAtIndex(linkIndex)
            
            self.dappLinkVC?.dappLinksView.linksTableView.reloadData()
            
            completion(success: true, error: nil)
        } else {
            completion(success: false, error: nil)
        }
    }
    
    func linkAtIndex(index: Int) -> Link? {
        if index < self.links.count {
            return self.links[index]
        }
        
        return nil
    }
    
    func linksCount() -> Int {
        return self.links.count
    }
    
    func canDeleteLinks() -> Bool {
        return true
    }
}

extension AddDappLinksVC: SwipeableViewDelegate {
    func didSwipe(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            self.performSegueWithIdentifier(self.finalDappSegueID, sender: self)
            
            break
        case .RightToLeft:
            self.dismissViewControllerAnimated(true, completion: nil)
            
            break
        }
    }
}
