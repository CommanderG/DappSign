//
//  AddDappViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class AddDappViewController: UIViewController, UITextViewDelegate {
    
    //ControlFlow
    var mode:String = "chooseColor"
    
    //Storyboard connections
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    //button labels
    @IBOutlet weak var banksiaLabel: UILabel!
    @IBOutlet weak var bellotaLabel: UILabel!
    @IBOutlet weak var captureLabel: UILabel!
    @IBOutlet weak var elsieLabel: UILabel!
    @IBOutlet weak var exoLabel: UILabel!
    @IBOutlet weak var klinicLabel: UILabel!
    @IBOutlet weak var printClearlyLabel: UILabel!
    @IBOutlet weak var sansationLabel: UILabel!
    @IBOutlet weak var walkwayLabel: UILabel!
    
    //Animation
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
     var originalCenter: CGPoint!
    
    //Design
    var currentColor = UIColor()
    var currentFont = UIFont()
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
    
    @IBOutlet weak var banksiaButtonOutlet: UIButton!
    @IBOutlet weak var bellotaButtonOutlet: UIButton!
    @IBOutlet weak var captureButtonOutlet: UIButton!
    @IBOutlet weak var elsieButtonOutlet: UIButton!
    @IBOutlet weak var exoButtonOutlet: UIButton!
    @IBOutlet weak var klinicButtonOutlet: UIButton!
    @IBOutlet weak var printClearlyButtonOutlet: UIButton!
    @IBOutlet weak var sansationButtonOutlet: UIButton!
    @IBOutlet weak var walkwayButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //AddDappColor Setup
        self.dappTextView.backgroundColor = UIColor.whiteColor()
        self.dappTextView.editable = false
        self.currentColor = self.dappColors.dappColorWheel["midnightBlue"]!
        self.currentFont = self.dappFonts.dappFontBook["exo"]!
        self.instructionLabel.text = "Pick a color. Swipe left to go back. Dapp to continue"
        
        //AddDappText Setup
        dappTextView.delegate = self

        //initialize animator
        animator = UIDynamicAnimator(referenceView: view)
        originalCenter = dappTextView.center
        
        //start with elements hidden to prep for animation
        dappTextView.hidden = true
        panelView.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        
        dappTextView.hidden = false
        dappTextView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappTextView.transform = CGAffineTransformConcat(scale, translate)
            
        }
        self.dappTextView.backgroundColor = self.currentColor
        self.dappTextView.alpha = 1
        
        panelView.hidden = false
        panelView.alpha = 0
        panelView.transform = CGAffineTransformMakeTranslation(0,200)
        
        spring(0.5) {
            self.panelView.alpha = 1
            self.panelView.transform = CGAffineTransformMakeTranslation(0, 0)
            
        }

        
        if mode == "chooseColor" {
            
            emeraldButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            carrotButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            pomegranateButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            wisteriaButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            sunflowerButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            turquoiseButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            amethystButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            
            
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
        } else if mode == "chooseFont" {
            banksiaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 200)
            bellotaButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            captureButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            elsieButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            exoButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            klinicButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            printClearlyButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            sansationButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            walkwayButtonOutlet.transform = CGAffineTransformMakeTranslation(0,200)
            
            
            springWithDelay(0.5, 0.02, {
                self.banksiaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.04, {
                self.bellotaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.06, {
                self.captureButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.08, {
                self.elsieButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.10, {
                self.exoButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.12, {
                self.klinicButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.14, {
                self.printClearlyButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.16, {
                self.sansationButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, 0.18, {
                self.walkwayButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            
        } else if mode == "addText"{
                println("thisworks")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func handleGesture(sender: AnyObject) {
        let location = sender.locationInView(view)
        let boxLocation = sender.locationInView(dappTextView)
        let myView = dappTextView
        let originalLocation = dappTextView.center
        
        dappTextView.center = location
        
        if sender.state == UIGestureRecognizerState.Began {
            animator.removeBehavior(snapBehavior)
            
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            animator.removeBehavior(attachmentBehavior)
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: originalCenter)
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            if translation.x > 100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dappTextView])
                gravity.gravityDirection = CGVectorMake(10, 0)
                animator.addBehavior(gravity)
                
                delay(0.1) {
                    if self.mode == "chooseColor"{
                        self.transitionAddText()
                        self.mode = "addText"
                        self.refreshView()
                    }else if self.mode == "addText"{
                        self.transitionChooseFont()
                        self.mode = "chooseFont"
                        self.refreshView()
                    }
                }
            }else if translation.x < -100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dappTextView])
                gravity.gravityDirection = CGVectorMake(-10, 0)
                animator.addBehavior(gravity)
                
                delay(0.1) {
                    if self.mode == "chooseColor"{
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }else if self.mode == "addText"{
                        self.reverseTransitionAddTextToChooseColor()
                        self.mode = "chooseColor"
                        self.refreshView()
                    }else if self.mode == "chooseFont"{
                        //do some shit
                        self.reverseTransitionChooseFontToAddText()
                        self.mode = "addText"
                        self.refreshView()
                    }
                }
            }
            
        }

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
    
    
    //font buttons
    @IBAction func banksiaButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["banksia"]!
        self.currentFont = dappFonts.dappFontBook["banksia"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func bellotaButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["bellota"]
        self.currentFont = dappFonts.dappFontBook["bellota"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func captureButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["capture"]
        self.currentFont = dappFonts.dappFontBook["capture"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func elsieButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["elsie"]
        self.currentFont = dappFonts.dappFontBook["elsie"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func exoButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["exo"]
        self.currentFont = dappFonts.dappFontBook["exo"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func klinicButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["klinic"]
        self.currentFont = dappFonts.dappFontBook["klinic"]!
        self.viewDidAppear(true)
    }

    @IBAction func printClearly(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["printClearly"]
        self.currentFont = dappFonts.dappFontBook["printClearly"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func sansationButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["banksia"]
        self.currentFont = dappFonts.dappFontBook["banksia"]!
        self.viewDidAppear(true)
    }
    
    @IBAction func walkwayButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["banksia"]
        self.currentFont = dappFonts.dappFontBook["banksia"]!
        self.viewDidAppear(true)
    }

    
    func transitionAddText(){
        self.dappTextView.editable = true
        self.instructionLabel.text = "Type your message. Only one rule: Contribute. Dapp to continue."
        dappTextView.editable = true
        characterCountLabel.hidden = false
        dappTextView.becomeFirstResponder()
    }
    
    func reverseTransitionAddTextToChooseColor(){
        self.dappTextView.editable = false
        self.instructionLabel.text = "Pick a color. Swipe left to go back. Dapp to continue."
        characterCountLabel.hidden = true
    }
    
    func transitionChooseFont(){
        self.dappTextView.editable = false
        //hide the color buttons
        emeraldButtonOutlet.hidden = true
        carrotButtonOutlet.hidden = true
        asbestosButtonOutlet.hidden = true
        pomegranateButtonOutlet.hidden = true
        wisteriaButtonOutlet.hidden = true
        sunflowerButtonOutlet.hidden = true
        asbestosButtonOutlet.hidden = true
        turquoiseButtonOutlet.hidden = true
        amethystButtonOutlet.hidden = true
        
        //unhide the font buttons
        banksiaButtonOutlet.hidden = false
        bellotaButtonOutlet.hidden = false
        captureButtonOutlet.hidden = false
        elsieButtonOutlet.hidden = false
        exoButtonOutlet.hidden = false
        klinicButtonOutlet.hidden = false
        printClearlyButtonOutlet.hidden = false
        sansationButtonOutlet.hidden = false
        walkwayButtonOutlet.hidden = false
        
        //unhide labels
        banksiaLabel.hidden = false
        bellotaLabel.hidden = false
        captureLabel.hidden = false
        elsieLabel.hidden = false
        exoLabel.hidden = false
        klinicLabel.hidden = false
        printClearlyLabel.hidden = false
        sansationLabel.hidden = false
        walkwayLabel.hidden = false
        
        self.instructionLabel.text = "Pick your font. Dapp to continue."
        characterCountLabel.hidden = true
        
        dappTextView.resignFirstResponder()
    }
    
    func reverseTransitionChooseFontToAddText(){
        self.panelView.hidden = true
        self.dappTextView.editable = true
        self.instructionLabel.text = "Type your message. Only one rule: Contribute. Dapp to continue."
        self.dappTextView.becomeFirstResponder()
        
    }
    
    //textView delegate function
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        
        var remainingChar:Int = 140 - newLength
        
        characterCountLabel.text = "\(remainingChar)"
        
        return(newLength > 140) ? false : true
        //editable when newLength is less than 140. not editable when it is
        
    }
    
    func refreshView() {
        
        animator.removeAllBehaviors()
        
        snapBehavior = UISnapBehavior(item:dappTextView, snapToPoint: self.originalCenter)
        attachmentBehavior.anchorPoint = originalCenter
        
        dappTextView.center = originalCenter
        
        viewDidAppear(true)
        
        
    }

    

    
}
