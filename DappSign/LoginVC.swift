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
    @IBOutlet weak var logInWithFacebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInWithFacebook(sender: AnyObject) {
        let permissions = [ "public_profile", "email" ]
        
        ViewHelper.disableButtons([ self.logInWithFacebookButton ])
        PFFacebookUtils.logInWithPermissions(permissions, block: {
            (user: PFUser?, error: NSError?) -> Void in
            ViewHelper.enableButtons([ self.logInWithFacebookButton ])
            
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    
                    self.performSegueWithIdentifier("showZipCode", sender: self)
                } else {
                    print("User logged in through Facebook!")
                    
                    self.performSegueWithIdentifier("showMainVC", sender: self)
                }
            } else if let error = error {
                print("Failed to log in on Facebook. Error: \(error)")
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
}
