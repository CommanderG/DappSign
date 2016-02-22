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

class AddDappViewController: UIViewController {
    
    //ControlFlow
    var mode:String = "chooseColor"
    
    //To be uploaded
    var dappColorString:String!
    var dappFontString:String! = "exo" // default
    var nameString:String!
    
    private var buttonsColors: [UIButton: Color] = [:]
    
    //Storyboard connections
    @IBOutlet weak var containerView: SwipeableView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
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
    var dappFonts = DappFonts()
    var originalLocation: CGPoint!
    
    //Button Outlets
    @IBOutlet weak var colorButtonLeftTop: UIButton!
    @IBOutlet weak var colorButtonMiddleTop: UIButton!
    @IBOutlet weak var colorButtonRightTop: UIButton!
    @IBOutlet weak var colorButtonLeftMiddle: UIButton!
    @IBOutlet weak var colorButtonMiddleMiddle: UIButton!
    @IBOutlet weak var colorButtonRightMiddle: UIButton!
    @IBOutlet weak var colorButtonLeftBottom: UIButton!
    @IBOutlet weak var colorButtonMiddleBottom: UIButton!
    @IBOutlet weak var colorButtonRightBottom: UIButton!
    
    @IBOutlet weak var banksiaButtonOutlet: UIButton!
    @IBOutlet weak var bellotaButtonOutlet: UIButton!
    @IBOutlet weak var captureButtonOutlet: UIButton!
    @IBOutlet weak var elsieButtonOutlet: UIButton!
    @IBOutlet weak var exoButtonOutlet: UIButton!
    @IBOutlet weak var klinicButtonOutlet: UIButton!
    @IBOutlet weak var printClearlyButtonOutlet: UIButton!
    @IBOutlet weak var sansationButtonOutlet: UIButton!
    @IBOutlet weak var walkwayButtonOutlet: UIButton!
    
    @IBOutlet weak var prohibitedWordsLabel: UILabel!
    
    private var showDappLinksSegueID = "showDappLinks"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //AddDappColor Setup
        self.panelView.hidden = false
        self.dappTextView.backgroundColor = UIColor.whiteColor()
        self.dappTextView.editable = false
        self.currentColor = DappColors.getColor(.Cinnabar)
        self.currentFont = self.dappFonts.dappFontBook["exo"]!
        
        //AddDappText Setup
        dappTextView.delegate = self
        
        //start with elements hidden to prep for animation
        dappTextView.hidden = true
        panelView.hidden = true
        
        self.containerView.delegate = self
        self.containerView.minTranslationX = 200.0
        
        self.prohibitedWordsLabel.hidden = true
        
        self.initButtonsColors()
        
        for (colorButton, color) in self.buttonsColors {
            colorButton.layer.cornerRadius = 12.0
            colorButton.layer.borderColor = UIColor.whiteColor().CGColor
            colorButton.layer.borderWidth = 2.0
            colorButton.backgroundColor = DappColors.getColor(color)
        }
        
        self.dappTextView.layer.cornerRadius = 10.0
        self.dappTextView.layer.borderColor = UIColor.whiteColor().CGColor
        self.dappTextView.layer.borderWidth = 2.0
        
        self.panelView.layer.borderColor = UIColor.whiteColor().CGColor
        self.panelView.layer.borderWidth = 2.0
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
            for (colorButton, _) in self.buttonsColors {
                colorButton.transform = CGAffineTransformMakeTranslation(0.0, 200.0)
            }
            
            springWithDelay(0.5, delay: 0.02, animations: {
                for (colorButton, _) in self.buttonsColors {
                    colorButton.transform = CGAffineTransformMakeTranslation(0, 0)
                }
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
    
    private func initButtonsColors() {
        self.buttonsColors[self.colorButtonLeftTop]      = .Cinnabar
        self.buttonsColors[self.colorButtonMiddleTop]    = .SummerSky
        self.buttonsColors[self.colorButtonRightTop]     = .Saffron
        self.buttonsColors[self.colorButtonLeftMiddle]   = .Cello
        self.buttonsColors[self.colorButtonMiddleMiddle] = .MediumCarmine
        self.buttonsColors[self.colorButtonRightMiddle]  = .MediumSeaGreen
        self.buttonsColors[self.colorButtonLeftBottom]   = .LightSeaGreen
        self.buttonsColors[self.colorButtonMiddleBottom] = .DeepLilac
        self.buttonsColors[self.colorButtonRightBottom]  = .Gamboge
    }
    
    @IBAction func applyColor(sender: AnyObject) {
        if let
            colorButton = sender as? UIButton,
            color = self.buttonsColors[colorButton] {
                self.currentColor = DappColors.getColor(color)
                self.dappColorString = color.rawValue
                
                self.dappTextView.backgroundColor = self.currentColor
                
                self.viewDidAppear(true)
        }
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

    
    func transitionAddText() {
        dappTextView.editable = true
        characterCountLabel.hidden = false
        panelView.hidden = true
        panelView.alpha = 0
        hashtagTextView.hidden = false
        dappTextView.becomeFirstResponder()
    }
    
    func reverseTransitionAddTextToChooseColor() {
        self.dappTextView.editable = false
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
        
        for (colorButton, _) in self.buttonsColors {
            colorButton.hidden = false
        }
    }
    
    func transitionChooseFont() {
        self.dappTextView.editable = false
        
        for (colorButton, _) in self.buttonsColors {
            colorButton.hidden = true
        }
        
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
        
        characterCountLabel.hidden = true
        
        dappTextView.resignFirstResponder()
        hashtagTextView.resignFirstResponder()
    }
    
    func reverseTransitionChooseFontToAddText() {
        self.panelView.hidden = true
        self.dappTextView.editable = true
        self.hashtagTextView.hidden = false
        self.dappTextView.becomeFirstResponder()
    }
    
    func getDapp() -> Dapp {
        let user = PFUser.currentUser()
        let dappStatement = self.dappTextView.text
        let lowercaseDappStatement = self.dappTextView.text.lowercaseString
        let dappFont = self.dappFontString
        let dappBackgroundColor = self.dappColorString
        let name = user["name"] as? String
        let userid = user.objectId
        let dappScore = 1
        let isDeleted = false
        let dappTypeId = DappTypeId.Secondary.rawValue
        
        var hashtagNames: [String] = []
        
        if let hashtagsText = self.hashtagTextView.text {
            hashtagNames = hashtagsText.characters.split(" ").map{ String($0) }
            hashtagNames = hashtagNames.map {
                // removes #
                $0[1...$0.characters.count - 1]
            }
        }
        
        let dapp = Dapp(
            dappStatement:          dappStatement,
            lowercaseDappStatement: lowercaseDappStatement,
            dappFont:               dappFont,
            dappBackgroundColor:    dappBackgroundColor,
            name:                   name,
            userid:                 userid,
            dappScore:              dappScore,
            isDeleted:              isDeleted,
            dappTypeId:             dappTypeId,
            hashtagNames:           hashtagNames
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
    func willShow(swipeDirection: SwipeDirection) {
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
    
    func didSwipe(swipeDirection: SwipeDirection) {}
}

extension AddDappViewController: UITextViewDelegate {
    func textView(textView: UITextView,
                  shouldChangeTextInRange range: NSRange,
                  replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar:Int = 140 - newLength
        
        characterCountLabel.text = "\(remainingChar)"
        
        return(newLength > 140) ? false : true
        //editable when newLength is less than 140. not editable when it is
    }
    
    func textViewDidChange(textView: UITextView) {
        let petitionMessage = textView.text
        let prohibitedPhrases = ProhibitedPhrases.prohibitedPhrasesInString(petitionMessage)
        
        if prohibitedPhrases.count > 0 {
            self.prohibitedWordsLabel.hidden = false
            self.containerView.canBeDraged = false
            
            let prohibitedPhrasesString = prohibitedPhrases.joinWithSeparator(", ")
            
            if prohibitedPhrases.count == 1 {
                self.prohibitedWordsLabel.text =
                "This petition can not be created because " +
                "it contains a prohibited word: \(prohibitedPhrasesString)."
            } else {
                self.prohibitedWordsLabel.text =
                "This petition can not be created because " +
                "it contains following prohibited words: \(prohibitedPhrasesString)."
            }
        } else {
            self.prohibitedWordsLabel.hidden = true
            self.containerView.canBeDraged = true
        }
    }
}
