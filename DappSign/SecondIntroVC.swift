//
//  SecondIntroVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/29/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class SecondIntroVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == "embedDappSignVC" {
            let dappSignVC = segue.destinationViewController
            
            DappSignViewsHelper.initViewLayer(dappSignVC.view)
        }
    }
}
