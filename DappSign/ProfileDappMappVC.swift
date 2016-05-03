//
//  ProfileDappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ProfileDappMappVC: UIViewController {
    internal static let storyboardID = "profileDappMappVC"
    
    @IBOutlet weak var mapWebView:           UIWebView!
    @IBOutlet weak var majoritySupportLabel: UILabel!
    @IBOutlet weak var topDistrict:          UILabel!
    @IBOutlet weak var secondTopDistrict:    UILabel!
    @IBOutlet weak var thirdTopDistrict:     UILabel!
    @IBOutlet weak var supportLabel:         UILabel!
    
    private var percentsVC: PercentsVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.percentsVC?.showPercents(62)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case PercentsVC.embedSegueID:
                self.percentsVC = segue.destinationViewController as? PercentsVC
            case _:
                break
            }
        }
    }
}
