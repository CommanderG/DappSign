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
    
    //To be uploaded
    var dappColorString:String!
    var dappFontString:String!
    var nameString:String!
    
    //Storyboard connections
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var hashtagTextView: UITextField!
    
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
        self.panelView.hidden = false
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
                    }else if self.mode == "chooseFont"{
                        self.submitDapp()
                        self.performSegueWithIdentifier("showFinalDappSubmitViewController", sender: self)
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
        dappColorString = "emerald"
        self.viewDidAppear(true)
    }
    
    @IBAction func carrotButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["carrot"]!
        currentColor = dappColors.dappColorWheel["carrot"]!
        dappColorString = "carrot"
        self.viewDidAppear(true)
    }
    
    @IBAction func peterRiverButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["peterRiver"]!
        currentColor = dappColors.dappColorWheel["peterRiver"]!
        dappColorString = "peterRiver"
        self.viewDidAppear(true)
    }
    
    @IBAction func pomegranateButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["pomegranate"]!
        currentColor = dappColors.dappColorWheel["pomegranate"]!
        dappColorString = "pomegranate"
        self.viewDidAppear(true)
    }
    
    @IBAction func wisteriaButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["wisteria"]!
        currentColor = dappColors.dappColorWheel["wisteria"]!
        dappColorString = "wisteria"
        self.viewDidAppear(true)
    }
    
    @IBAction func sunflowerButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["sunFlower"]!
        currentColor = dappColors.dappColorWheel["sunFlower"]!
        dappColorString = "sunFlower"
        self.viewDidAppear(true)
    }
    
    @IBAction func asbestosButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["asbestos"]!
        currentColor = dappColors.dappColorWheel["asbestos"]!
        dappColorString = "asbestos"
        self.viewDidAppear(true)
    }
    
    @IBAction func turqoiseButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["turquoise"]!
        currentColor = dappColors.dappColorWheel["turquoise"]!
        dappColorString = "turquoise"
        self.viewDidAppear(true)
    }
    
    @IBAction func amethystButton(sender: AnyObject) {
        self.dappTextView.backgroundColor = dappColors.dappColorWheel["amethyst"]!
        currentColor = dappColors.dappColorWheel["amethyst"]!
        dappColorString = "amethyst"
        self.viewDidAppear(true)
    }
    
    
    //font buttons
    @IBAction func banksiaButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["banksia"]!
        self.currentFont = dappFonts.dappFontBook["banksia"]!
        dappFontString = "banksia"
        self.viewDidAppear(true)
    }
    
    @IBAction func bellotaButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["bellota"]!
        self.currentFont = dappFonts.dappFontBook["bellota"]!
        dappFontString = "bellota"
        self.viewDidAppear(true)
    }
    
    @IBAction func captureButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["captureIt"]!
        self.currentFont = dappFonts.dappFontBook["captureIt"]!
        dappFontString = "captureIt"
        self.viewDidAppear(true)
    }
    
    @IBAction func elsieButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["elsie"]!
        self.currentFont = dappFonts.dappFontBook["elsie"]!
        dappFontString = "elsie"
        self.viewDidAppear(true)
    }
    
    @IBAction func exoButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["exo"]!
        self.currentFont = dappFonts.dappFontBook["exo"]!
        dappFontString = "exo"
        self.viewDidAppear(true)
    }
    
    @IBAction func klinicButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["klinicSlab"]!
        self.currentFont = dappFonts.dappFontBook["klinicSlab"]!
        dappFontString = "klinicSlab"
        self.viewDidAppear(true)
    }

    @IBAction func printClearly(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["printClearly"]
        self.currentFont = dappFonts.dappFontBook["printClearly"]!
        dappFontString = "printClearly"
        self.viewDidAppear(true)
    }
    
    @IBAction func sansationButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["banksia"]!
        self.currentFont = dappFonts.dappFontBook["banksia"]!
        dappFontString = "banksia"
        self.viewDidAppear(true)
    }
    
    @IBAction func walkwayButton(sender: AnyObject) {
        self.dappTextView.font = dappFonts.dappFontBook["walkwaySemiBold"]!
        self.currentFont = dappFonts.dappFontBook["walkwaySemiBold"]!
        dappFontString = "walkwaySemiBold"
        self.viewDidAppear(true)
    }

    
    func transitionAddText(){
        self.instructionLabel.text = "Only one rule: Contribute. Dapp to continue."
        dappTextView.editable = true
        characterCountLabel.hidden = false
        panelView.hidden = true //why doesnt this work????
        panelView.alpha = 0
        hashtagTextView.hidden = false
        dappTextView.becomeFirstResponder()
    }
    
    func reverseTransitionAddTextToChooseColor(){
        self.dappTextView.editable = false
        self.instructionLabel.text = "Pick a color. Swipe left to go back. Dapp to continue."
        characterCountLabel.hidden = true
        hashtagTextView.hidden = true
        panelView.hidden = false
        
        //hide all of the font buttons/labels in case the user goes all the way to choose font and then goes all the way back to choose color
        banksiaButtonOutlet.hidden = true
        bellotaButtonOutlet.hidden = true
        captureButtonOutlet.hidden = true
        elsieButtonOutlet.hidden = true
        exoButtonOutlet.hidden = true
        klinicButtonOutlet.hidden = true
        printClearlyButtonOutlet.hidden = true
        sansationButtonOutlet.hidden = true
        walkwayButtonOutlet.hidden = true
        
        banksiaLabel.hidden = true
        bellotaLabel.hidden = true
        captureLabel.hidden = true
        elsieLabel.hidden = true
        exoLabel.hidden = true
        klinicLabel.hidden = true
        printClearlyLabel.hidden = true
        sansationLabel.hidden = true
        walkwayLabel.hidden = true
        
        //unhide the color buttons
        emeraldButtonOutlet.hidden = false
        carrotButtonOutlet.hidden = false
        asbestosButtonOutlet.hidden = false
        pomegranateButtonOutlet.hidden = false
        wisteriaButtonOutlet.hidden = false
        sunflowerButtonOutlet.hidden = false
        asbestosButtonOutlet.hidden = false
        turquoiseButtonOutlet.hidden = false
        amethystButtonOutlet.hidden = false

        
        
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
        
        hashtagTextView.hidden = true
        
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
    
    func submitDapp() {
        nameString = PFUser.currentUser().objectForKey("name") as String!
        var dapp:PFObject = PFObject(className: "Dapps")
        dapp["dappStatement"] = dappTextView.text
        dapp["lowercaseDappStatement"] = dappTextView.text.lowercaseString
        dapp["dappFont"] = self.dappFontString
        dapp["dappBackgroundColor"] = dappColorString
        dapp["name"] = nameString
        dapp["userid"] = PFUser.currentUser().objectId
        dapp["dappScore"] = 1
        dapp["isDeleted"] = false
        
        let mainBundle = NSBundle.mainBundle()
        
        if let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String] {
            if contains(adminUsersIDs, PFUser.currentUser().objectId) {
                dapp["dappTypeId"] = DappTypeId.Secondary.rawValue
            }
        }
        
        var hashtagNames = split(self.hashtagTextView.text) { $0 == " " }
        hashtagNames = hashtagNames.map {
            // removes #
            $0[1...countElements($0) - 1]
        }
        
        Requests.uploadHashtags(hashtagNames, completion: {
            (hashtags: [PFObject]?, error: NSError!) -> Void in
            if error != nil {
                println("Failed to upload hashtags \(hashtagNames). Error: \(error)")
            }
            
            if let hashtags = hashtags {
                let hashtagsRelation = dapp.relationForKey("hashtags")
                
                for hashtag in hashtags {
                    hashtagsRelation.addObject(hashtag)
                }
            }
            
            dapp.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    println("Dapp created with id: \(dapp.objectId)")
                } else {
                    println("%@" , error)
                }
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if segue.identifier == "showFinalDappSubmitViewController"{
            let finalDappSubmitVC:FinalDappSubmitViewController = segue.destinationViewController as FinalDappSubmitViewController
            
            finalDappSubmitVC.dappColorString = self.dappColorString
            finalDappSubmitVC.dappStatementString = self.dappTextView.text
            finalDappSubmitVC.dappFontString = self.dappFontString
            finalDappSubmitVC.nameString = self.nameString
        }
      
    }

    

    
}

extension String {
    subscript(r: Range<Int>) -> String {
        get {
            let rangeStart = advance(self.startIndex, r.startIndex, self.endIndex)
            let rangeEnd = advance(rangeStart, r.endIndex - r.startIndex, self.endIndex)
            let range = Range(start: rangeStart, end: rangeEnd)
            
            return self.substringWithRange(range)
        }
    }
    
    private func containsOnlyDigitsOrLetters() -> Bool {
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        for uni in self.unicodeScalars {
            if letters.longCharacterIsMember(uni.value) {
                continue
            }
            
            if digits.longCharacterIsMember(uni.value) {
                continue
            }
            
            return false
        }
        
        return true
    }
    
    func isHashtag() -> Bool {
        if countElements(self) < 2 {
            return false
        }
        
        if first(self) != "#" {
            return false
        }
        
        let rest = self[1...countElements(self)]
        
        return rest.containsOnlyDigitsOrLetters()
    }
    
}

extension AddDappViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text as NSString
        let newText = currentText.stringByReplacingCharactersInRange(range, withString: string)
        
        if countElements(newText) < 2 {
            if first(newText) == "#" {
                return true
            }
            
            return false
        }
        
        if newText.rangeOfString("  ") != nil {
            return false
        }
        
        if newText.rangeOfString("# ") != nil {
            return false
        }
        
        let possibleHashtags = split(newText) { $0 == " " }
        
        for possibleHashtag in possibleHashtags {
            if possibleHashtag == "#" {
                continue
            }
            
            if !possibleHashtag.isHashtag() {
                return false
            }
        }
        
        return true
    }
}
