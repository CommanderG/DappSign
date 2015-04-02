//
//  ViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookLoginButton(sender: AnyObject) {
        let loginWithFacebookButton = sender as UIButton
        var permissions = ["public_profile", "email"]
        loginWithFacebookButton.userInteractionEnabled = false
        loginWithFacebookButton.alpha = 0.5
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { [unowned self] (user, error) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                } else {
                    println("User logged in through Facebook!")
                }
                
                Requests.addUserIdDappScore(user.objectId)
                
                self.performSegueWithIdentifier("showHomeViewController", sender: self)
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
            
            loginWithFacebookButton.userInteractionEnabled = true
            loginWithFacebookButton.alpha = 1.0
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

