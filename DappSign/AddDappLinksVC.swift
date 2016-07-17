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
    private let finalDappSegueID        = "finalDappSegue"
    
    private var tableView : UITableView? = nil
    private var links     : [Link]       = []
    
    internal var dapp: Dapp? = nil
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(AddDappLinksVC.handleKeyboardWillShowNotification(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(AddDappLinksVC.handleKeyboardWillHideNotification(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.minTranslationX = 150.0
        self.containerView.appearanceDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.containerView.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case embedDappLinksVCSegueID:
            let dappLinksVC = segue.destinationViewController as? DappLinksVC
            
            dappLinksVC?.initWithMode(.AddEdit, andLinks: [])
            dappLinksVC?.addBorder()
            
            dappLinksVC?.delegate = self
            
            self.tableView = dappLinksVC?.linksTableView
            
            if let
                dappBgColoName = dapp?.dappBackgroundColor,
                colorName = ColorName(rawValue: dappBgColoName) {
                    dappLinksVC?.view.backgroundColor =
                        DappColors.colorWithColorName(colorName)
            }
        case finalDappSegueID:
            let finalDappSubmitVC =
                segue.destinationViewController as? FinalDappSubmitViewController
            
            finalDappSubmitVC?.dapp = self.dapp
            finalDappSubmitVC?.links = self.links
        case _:
            break
        }
    }
    
    // MARK: - keyboard notifications
    
    internal func handleKeyboardWillShowNotification(notification: NSNotification) {
        let keyboardBoundsObject = notification.userInfo?["UIKeyboardBoundsUserInfoKey"]
        
        guard let keyboardBounds = (keyboardBoundsObject as? NSValue)?.CGRectValue() else {
            return
        }
        
        let topInset: CGFloat = 0.0
        let leftInset: CGFloat = 0.0
        let bottomInset: CGFloat = keyboardBounds.height
        let rightInset: CGFloat = 0.0
        let contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
        
        self.tableView?.contentInset = contentInset
    }
    
    internal func handleKeyboardWillHideNotification(notification: NSNotification) {
        self.tableView?.contentInset = UIEdgeInsetsZero
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

extension AddDappLinksVC: SwipeableViewAppearanceDelegate {
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
}
