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
        if let segueID = segue.identifier {
            switch segueID {
            case embedDappLinksVCSegueID:
                let dappLinksVC = segue.destinationViewController as? DappLinksVC
                
                dappLinksVC?.initWithMode(.AddEdit, andLinks: [])
                
                dappLinksVC?.delegate = self
            case finalDappSegueID:
                let finalDappSubmitVC =
                    segue.destinationViewController as? FinalDappSubmitViewController
                
                finalDappSubmitVC?.dapp = self.dapp
                finalDappSubmitVC?.links = self.links
            case _:
                break
            }
        }
    }
}

extension AddDappLinksVC: DappLinksVCDelegate {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void) {
        self.links.append(link)
        
        completion(success: true, error: nil)
    }
    
    func deleteLink(linkToDelete: Link, completion: (success: Bool, error: NSError?) -> Void) {
        for index in 0 ... self.links.count - 1 {
            let link = self.links[index]
            
            if link == linkToDelete {
                self.links.removeAtIndex(index)
            }
        }
        
        completion(success: true, error: nil)
    }
    
    func openLinkURL(linkURL: NSURL) {}
}

extension AddDappLinksVC: SwipeableViewDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            self.performSegueWithIdentifier(self.finalDappSegueID, sender: self)
            
            break
        case .RightToLeft:
            self.dismissViewControllerAnimated(true, completion: nil)
            
            break
        }
    }
    
    func didSwipe(swipeDirection: SwipeDirection) {}
}
