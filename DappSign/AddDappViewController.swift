//
//  AddDappViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

struct Dapp {
    var dappStatement: String?
    var lowercaseDappStatement: String?
    var dappFont: String?
    var dappBackgroundColor: String?
    var name: String?
    var userid: String?
    var dappScore: Int
    var isDeleted: Bool
    var dappTypeId: String?
    var hashtagNames: [String]
}

class AddDappViewController: UIViewController, UITextViewDelegate {
    
    //ControlFlow
    var mode:String = "chooseColor"
    
    //To be uploaded
    var dappColorString:String!
    var dappFontString:String! = "exo" // default
    var nameString:String!
    
    //Storyboard connections
    @IBOutlet weak var containerView: SwipeableView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
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
    
    private var showDappLinksSegueID = "showDappLinks"
    
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
        
        //start with elements hidden to prep for animation
        dappTextView.hidden = true
        panelView.hidden = true
        
        self.containerView.delegate = self
        self.containerView.minTranslationX = 200.0
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
            
            
            springWithDelay(0.5, delay: 0.02, animations: {
                self.emeraldButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
                
            })
            springWithDelay(0.5, delay: 0.04, animations: {
                self.carrotButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.06, animations: {
                self.peterRiverOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.08, animations: {
                self.pomegranateButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.10, animations: {
                self.wisteriaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.12, animations: {
                self.sunflowerButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.14, animations: {
                self.asbestosButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.16, animations: {
                self.turquoiseButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.18, animations: {
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
            
            
            springWithDelay(0.5, delay: 0.02, animations: {
                self.banksiaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.04, animations: {
                self.bellotaButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.06, animations: {
                self.captureButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.08, animations: {
                self.elsieButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.10, animations: {
                self.exoButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.12, animations: {
                self.klinicButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.14, animations: {
                self.printClearlyButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.16, animations: {
                self.sansationButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            springWithDelay(0.5, delay: 0.18, animations: {
                self.walkwayButtonOutlet.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            
        } else if mode == "addText"{
                print("thisworks")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        self.instructionLabel.text = "Type your message. Only one rule: Contribute."
        dappTextView.editable = true
        characterCountLabel.hidden = false
        panelView.hidden = true
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
        hashtagTextView.resignFirstResponder()
    }
    
    func reverseTransitionChooseFontToAddText(){
        self.panelView.hidden = true
        self.dappTextView.editable = true
        self.instructionLabel.text = "Type your message. Only one rule: Contribute."
        self.hashtagTextView.hidden = false
        self.dappTextView.becomeFirstResponder()
        
    }
    
    //textView delegate function
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        
        let remainingChar:Int = 140 - newLength
        
        characterCountLabel.text = "\(remainingChar)"
        
        return(newLength > 140) ? false : true
        //editable when newLength is less than 140. not editable when it is
        
    }
    
    func getDapp() -> Dapp {
        func getDappTypeID() -> String? {
            let mainBundle = NSBundle.mainBundle()
            let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String]
            
            if let adminUsersIDs = adminUsersIDs {
                if adminUsersIDs.contains(PFUser.currentUser().objectId) {
                    return DappTypeId.Secondary.rawValue
                }
            }
            
            return nil
        }
        
        let user = PFUser.currentUser()
        let dappStatement = self.dappTextView.text
        let lowercaseDappStatement = self.dappTextView.text.lowercaseString
        let dappFont = self.dappFontString
        let dappBackgroundColor = self.dappColorString
        let name = user["name"] as? String
        let userid = user.objectId
        let dappScore = 1
        let isDeleted = false
        let dappTypeId = getDappTypeID()
        
        var hashtagNames: [String] = []
        
        if let hashtagsText = self.hashtagTextView.text {
            hashtagNames = hashtagsText.characters.split(" ").map{ String($0) }
            hashtagNames = hashtagNames.map {
                // removes #
                $0[1...$0.characters.count - 1]
            }
        }
        
        let dapp = Dapp(
            dappStatement:          dappStatement
        ,   lowercaseDappStatement: lowercaseDappStatement
        ,   dappFont:               dappFont
        ,   dappBackgroundColor:    dappBackgroundColor
        ,   name:                   name
        ,   userid:                 userid
        ,   dappScore:              dappScore
        ,   isDeleted:              isDeleted
        ,   dappTypeId:             dappTypeId
        ,   hashtagNames:           hashtagNames
        )
        
        return dapp
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.showDappLinksSegueID {
            let linksVC = segue.destinationViewController as! AddDappLinksVC
            linksVC.dapp = self.getDapp()
        }
    }
}

extension String {
    subscript(r: Range<Int>) -> String {
        get {
            let rangeStart = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
            let rangeEnd = rangeStart.advancedBy(r.endIndex - r.startIndex, limit: self.endIndex)
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
        if self.characters.count < 2 {
            return false
        }
        
        if self.characters.first != "#" {
            return false
        }
        
        let rest = self[1...self.characters.count]
        
        return rest.containsOnlyDigitsOrLetters()
    }
    
}

extension AddDappViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let currText = textField.text as NSString? {
            let newText = currText.stringByReplacingCharactersInRange(range, withString: string)
            
            if newText.characters.count < 2 {
                if newText.characters.first == "#" {
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
            
            let possibleHashtags = newText.characters.split { $0 == " " }.map { String($0) }
            
            for possibleHashtag in possibleHashtags {
                if possibleHashtag == "#" {
                    continue
                }
                
                if !possibleHashtag.isHashtag() {
                    return false
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}

extension AddDappViewController: SwipeableViewDelegate {
    func didSwipe(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            if self.mode == "chooseColor" {
                self.transitionAddText()
                self.mode = "addText"
                self.viewDidAppear(true)
            } else if self.mode == "addText" {
                self.transitionChooseFont()
                self.mode = "chooseFont"
                self.viewDidAppear(true)
            } else if self.mode == "chooseFont" {
                self.performSegueWithIdentifier(self.showDappLinksSegueID, sender: self)
            }
            
            break
        case .RightToLeft:
            if self.mode == "chooseColor" {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else if self.mode == "addText" {
                self.reverseTransitionAddTextToChooseColor()
                self.mode = "chooseColor"
                self.viewDidAppear(true)
            } else if self.mode == "chooseFont" {
                //do some shit
                self.reverseTransitionChooseFontToAddText()
                self.mode = "addText"
                self.viewDidAppear(true)
            }
            
            break
        }
    }
}
