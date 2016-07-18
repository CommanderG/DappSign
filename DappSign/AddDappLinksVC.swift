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
    
    private let finalDappSegueID = "finalDappSegue"
    
    private var dappLinksVC : DappLinksVC? = nil
    private var dappSignVC  : DappSignVC?  = nil
    private var links       : [Link]       = []
    
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
        
        guard
            let dappSignView = self.dappSignVC?.view,
            let dappLinksView = self.dappLinksVC?.view
            else { return }
        
        let dapp = self.getDapp()
        
        self.dappSignVC?.showDapp(dapp)
        
        dappSignView.hidden = false
        dappLinksView.hidden = true
        
        delay(0.75) {
            ViewHelper.flipWithDuration(0.5,
                view1: dappSignView,
                view2: dappLinksView,
                completion: nil
            )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case "embedDappLinksVCSegue":
            self.dappLinksVC = segue.destinationViewController as? DappLinksVC
            
            self.dappLinksVC?.initWithMode(.AddEdit, andLinks: [])
            self.dappLinksVC?.addBorder()
            
            self.dappLinksVC?.delegate = self
            
            if let
                dappBgColoName = dapp?.dappBackgroundColor,
                colorName = ColorName(rawValue: dappBgColoName) {
                let color = DappColors.colorWithColorName(colorName)
                
                self.dappLinksVC?.view.backgroundColor = color
            }
            
            break
        case "embedDappSignVCSegue":
            self.dappSignVC = segue.destinationViewController as? DappSignVC
            
            break
        case finalDappSegueID:
            let finalDappSubmitVC =
                segue.destinationViewController as? FinalDappSubmitViewController
            
            finalDappSubmitVC?.dapp = self.dapp
            finalDappSubmitVC?.links = self.links
            
            break
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
        
        self.dappLinksVC?.linksTableView?.contentInset = contentInset
    }
    
    internal func handleKeyboardWillHideNotification(notification: NSNotification) {
        self.dappLinksVC?.linksTableView?.contentInset = UIEdgeInsetsZero
    }
    
    // MARK: - 
    
    private func getDapp() -> Dapp {
        let user                   = PFUser.currentUser()
        let dappStatement          = NewDappParams.message
        let lowercaseDappStatement = NewDappParams.message.lowercaseString
        let dappFont               = NewDappParams.fontName.rawValue
        let dappBackgroundColor    = NewDappParams.colorName.rawValue
        let name                   = user["name"] as? String
        let userid                 = user.objectId
        let dappScore              = 1
        let isDeleted              = false
        let hashtagNames: [String] = []
        
        let dapp = Dapp(
            dappStatement          :          dappStatement,
            lowercaseDappStatement : lowercaseDappStatement,
            dappFont               :               dappFont,
            dappBackgroundColor    :    dappBackgroundColor,
            name                   :                   name,
            userid                 :                 userid,
            dappScore              :              dappScore,
            isDeleted              :              isDeleted,
            hashtagNames           :           hashtagNames
        )
        
        return dapp
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
