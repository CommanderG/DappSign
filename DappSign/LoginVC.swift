//
//  ViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//  Revisited on 8/23 to test.
//  Giri Github push test 10/23

import UIKit

class LoginVC: UIViewController {
    private let segueShowZipCode    = "showZipCode"
    private let segueShowDailyDapp  = "showDailyDapp"
    private let segueShowEmailLogin = "showEmailLogin"
    
    private var shouldShowDailyDapp = false
    
    @IBOutlet weak var logInWithFacebookButton : UIButton!
    @IBOutlet weak var logInWithEmailButton    : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let registerWithEmailLabel = self.logInWithEmailButton.titleLabel,
            let text = registerWithEmailLabel.text
            else { return; }
        
        let attributedText = NSMutableAttributedString(string: text)
        let textRange = NSMakeRange(0, text.characters.count)
        
        attributedText.addAttribute(NSUnderlineStyleAttributeName,
            value: NSUnderlineStyle.StyleSingle.rawValue,
            range: textRange
        )
        
        registerWithEmailLabel.attributedText = attributedText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldShowDailyDapp {
            self.performSegueWithIdentifier(self.segueShowDailyDapp, sender: self)
        }
    }
    
    @IBAction func logInWithFacebook(sender: AnyObject) {
        let permissions = [ "public_profile", "email" ]
        
        ViewHelper.disableButtons([ self.logInWithFacebookButton ])
        PFFacebookUtils.logInWithPermissions(permissions, block: {
            (user: PFUser?, error: NSError?) -> Void in
            ViewHelper.enableButtons([ self.logInWithFacebookButton ])
            
            if let user = user {
                LocalStorage.saveUserIsNew(user.isNew)
                
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    
                    UserHelper.initCurrentUserWithTheirFacebookProfileInformation {
                        self.performSegueWithIdentifier(self.segueShowZipCode, sender: self)
                    }
                } else {
                    print("User logged in through Facebook!")
                    
                    self.performSegueWithIdentifier(self.segueShowDailyDapp, sender: self)
                }
            } else if let error = error {
                print("Failed to log in on Facebook. Error: \(error)")
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case segueShowZipCode:
            let zipCodeVC = segue.destinationViewController as? ZipCodeViewController
            
            zipCodeVC?.delegate = self
        case segueShowEmailLogin:
            let emailLoginVC = segue.destinationViewController as? EmailLoginVC
            
            emailLoginVC?.delegate = self
        case _:
            break
        }
    }
}

extension LoginVC: ZipCodeDelegate {
    func didSaveRepresentativeAndDistrictInformation(success: Bool) {
        self.shouldShowDailyDapp = success
    }
}

extension LoginVC: EmailLoginDelegate {
    func didRegister() {
        LocalStorage.saveUserIsNew(true)
        self.performSegueWithIdentifier(self.segueShowZipCode, sender: self)
    }
    
    func didSignIn() {
        self.performSegueWithIdentifier(self.segueShowDailyDapp, sender: self)
    }
}
