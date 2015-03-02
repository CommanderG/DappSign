//
//  AddDappViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class AddDappViewController: UIViewController {
    //Storyboard connections
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    //Animators
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    //Design
    var currentColor = UIColor()
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    var originalLocation: CGPoint!
    
    //Button Outlets
    @IBOutlet weak var emeraldButtonOutlet: UIButton!
    @IBOutlet weak var carrotButtonOutlet: UIButton!
    @IBOutlet weak var peterRiverOutlet: UIButton!
    @IBOutlet weak var pomegranateButtonOutlet: UIButton!
    @IBOutlet weak var wisteriaButtonOutlet: UIButton!
    @IBOutlet weak var sunflowerButtonOutlet: UIButton!
    @IBOutlet weak var asbestosButtonOutlet: UIButton!
    @IBOutlet weak var turquoiseButtonOutlet: UIButton!
    @IBOutlet weak var amethystButtonOutlet: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dappTextView.backgroundColor = UIColor.whiteColor()
        self.currentColor = self.dappColors.dappColorWheel["midnightBlue"]!

        //initialize animator
        animator = UIDynamicAnimator(referenceView: view)
        
        //start with elements hidden to prep for animation
        dappTextView.hidden = true
        panelView.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        dappTextView.hidden = false
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dappTextView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappTextView.transform = CGAffineTransformConcat(scale, translate)
            self.dappTextView.backgroundColor = self.currentColor
            self.dappTextView.alpha = 1
        }
        
        
        panelView.hidden = false
        panelView.alpha = 0
        panelView.transform = CGAffineTransformMakeTranslation(0,200)
        emeraldButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        carrotButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        pomegranateButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        wisteriaButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        sunflowerButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        turquoiseButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        amethystButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
        
        spring(0.5) {
            self.panelView.alpha = 1
            self.panelView.transform = CGAffineTransformMakeTranslation(0, 0)
            
        }
        
        springWithDelay(0.5, 0.02, {
            self.emeraldButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            
        })
        springWithDelay(0.5, 0.04, {
            self.carrotButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.06, {
            self.peterRiverOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.08, {
            self.pomegranateButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.10, {
            self.wisteriaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.12, {
            self.sunflowerButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.14, {
            self.asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.16, {
            self.turquoiseButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        springWithDelay(0.5, 0.18, {
            self.amethystButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func handleGesture(sender: AnyObject) {
    }
    
    
    //Color Buttons
    @IBAction func emeraldButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["emerald"]!
        currentColor = dappColors.dappColorWheel["emerald"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func carrotButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["carrot"]!
        currentColor = dappColors.dappColorWheel["carrot"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func peterRiverButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["peterRiver"]!
        currentColor = dappColors.dappColorWheel["peterRiver"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func pomegranateButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["pomegranate"]!
        currentColor = dappColors.dappColorWheel["pomegranate"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func wisteriaButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["wisteria"]!
        currentColor = dappColors.dappColorWheel["wisteria"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func sunflowerButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["sunFlower"]!
        currentColor = dappColors.dappColorWheel["sunFlower"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func asbestosButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["asbestos"]!
        currentColor = dappColors.dappColorWheel["asbestos"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func turqoiseButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["turquoise"]!
        currentColor = dappColors.dappColorWheel["turquoise"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func amethystButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["amethyst"]!
        currentColor = dappColors.dappColorWheel["amethyst"]!
        self.viewDidAppear(true)
    }
    
    
}
