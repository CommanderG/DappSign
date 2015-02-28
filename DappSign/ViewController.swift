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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookLoginButton(sender: AnyObject) {
        
        var permissions = ["public_profile" , "email"]
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user:PFUser!, error:NSError!) -> Void in
            if user == nil{
                NSLog("User cancelled the Facebook login.")
            }else if user.isNew{
                NSLog("User signed up and logged in through Facebook")
            }else{
                NSLog("User logged in through Facebook!")
            }
        })
        
        performSegueWithIdentifier("showHomeViewController", sender: self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}

