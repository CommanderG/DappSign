//
//  HomeViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //storyboard elements
    @IBOutlet weak var dappView: UIView!
    @IBOutlet weak var dappHeaderView: UIView!
    @IBOutlet weak var dappFooterView: UIView!
    @IBOutlet weak var dappCounterView: UIView!
    @IBOutlet weak var dappLogoView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    //array to be loaded from parse
    var dappData: NSMutableArray! = NSMutableArray()
    var count = 0 //index
    
    //dapp Colors and fonts
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    
    //animator behavior variables
    var originalLocation: CGPoint!
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalLocation = dappView.center
        animator = UIDynamicAnimator(referenceView: view)
        dappView.alpha = 0
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dappView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        
        if count < dappData.count{
            self.dappTextView.text = dappData[count].objectForKey("dappStatement") as String!
            self.dappTextView.font = dappFonts.dappFontBook[dappData[count].objectForKey("dappFont") as String!]
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappData[count].objectForKey("dappBackgroundColor") as String!]
        } else {
            self.dappTextView.text = "No more DappCards. Feel free to submit your own!"
            self.dappTextView.font  = dappFonts.dappFontBook["exo"]!
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
        }
        
        dappView.alpha = 1
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func refreshView() {
        count++
        
        animator.removeAllBehaviors()
        
        snapBehavior = UISnapBehavior(item:dappView, snapToPoint: view.center)
        attachmentBehavior.anchorPoint = view.center
        
        dappView.center = view.center ///uh......dunno
        
        viewDidAppear(true)
        
        
    }

    
    @IBAction func handleGesture(sender: AnyObject) {
    }
    
    //load data from parse
    func loadData(){
        var findDappDeckData:PFQuery = PFQuery(className: "Dapps")
        
        findDappDeckData.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if error == nil{
                for object in objects{
                    var dapp:PFObject = object as PFObject
                    self.dappData.addObject(dapp)
                    
                }
            }
        }
    }


}
