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

enum Mode {
    case ChooseColor
    case ChooseFont
    case AddText
}

class AddDappViewController: UIViewController {
    @IBOutlet weak var dappContainerSwipeableView:         SwipeableView!
    @IBOutlet weak var dappTextView:                       UITextView!
    @IBOutlet weak var hashtagTextView:                    UITextField!
    @IBOutlet weak var buttonsContainerViewsContainerView: UIView!
    @IBOutlet weak var colorButtonsContainerView:          UIView!
    @IBOutlet weak var fontButtonsContainerView:           UIView!
    
    @IBOutlet weak var colorButtonLeftTop:      UIButton!
    @IBOutlet weak var colorButtonMiddleTop:    UIButton!
    @IBOutlet weak var colorButtonRightTop:     UIButton!
    @IBOutlet weak var colorButtonLeftMiddle:   UIButton!
    @IBOutlet weak var colorButtonMiddleMiddle: UIButton!
    @IBOutlet weak var colorButtonRightMiddle:  UIButton!
    @IBOutlet weak var colorButtonLeftBottom:   UIButton!
    @IBOutlet weak var colorButtonMiddleBottom: UIButton!
    @IBOutlet weak var colorButtonRightBottom:  UIButton!
    
    @IBOutlet weak var fontButtonLeftTop:      UIButton!
    @IBOutlet weak var fontButtonMiddleTop:    UIButton!
    @IBOutlet weak var fontButtonRightTop:     UIButton!
    @IBOutlet weak var fontButtonLeftMiddle:   UIButton!
    @IBOutlet weak var fontButtonMiddleMiddle: UIButton!
    @IBOutlet weak var fontButtonRightMiddle:  UIButton!
    @IBOutlet weak var fontButtonLeftBottom:   UIButton!
    @IBOutlet weak var fontButtonMiddleBottom: UIButton!
    @IBOutlet weak var fontButtonRightBottom:  UIButton!
    
    @IBOutlet weak var prohibitedWordsLabel: UILabel!
    
    private let showDappLinksSegueID = "showDappLinks"
    
    private var mode = Mode.ChooseColor
    private var dappColorName = ColorName.Cinnabar
    private var dappFontName = FontName.Exo
    
    private var colorButtonsColorNames: [UIButton: ColorName] = [:]
    private var fontButtonsFontNames: [UIButton: FontName] = [:]
    
    private var nameString: String!
    
    private var originalLocation: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dappTextView.editable = false
        
        // AddDappText Setup
        self.dappTextView.delegate = self
        
        self.dappContainerSwipeableView.delegate = self
        self.dappContainerSwipeableView.minTranslationX = 200.0
        
        self.prohibitedWordsLabel.hidden = true
        
        self.initColorButtonsColors()
        self.initFontButtonsFonts()
        
        for (colorButton, colorName) in self.colorButtonsColorNames {
            colorButton.layer.cornerRadius = 12.0
            colorButton.layer.borderColor = UIColor.whiteColor().CGColor
            colorButton.layer.borderWidth = 2.0
            colorButton.backgroundColor = DappColors.colorWithColorName(colorName)
        }
        
        for (fontButton, fontName) in self.fontButtonsFontNames {
            fontButton.layer.cornerRadius = 12.0
            fontButton.layer.borderColor = UIColor.whiteColor().CGColor
            fontButton.layer.borderWidth = 2.0
            fontButton.backgroundColor = UIColor.clearColor()
            
            let fontFileName = DappFonts.fontFileNameWithName(fontName)
            
            fontButton.titleLabel?.font = UIFont(name: fontFileName, size: 18.0)
            
            let title = DappFonts.fontDisplayNameWithFontName(fontName)
            
            fontButton.setTitle(title, forState: .Normal)
        }
        
        self.dappTextView.layer.cornerRadius = 10.0
        self.dappTextView.layer.borderColor = UIColor.whiteColor().CGColor
        self.dappTextView.layer.borderWidth = 2.0
        
        self.buttonsContainerViewsContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonsContainerViewsContainerView.layer.borderWidth = 2.0
        
        self.dappTextView.backgroundColor = DappColors.colorWithColorName(self.dappColorName)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dappContainerSwipeableView.hidden = true
        self.hashtagTextView.hidden = true
        self.buttonsContainerViewsContainerView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.prepareViewsForCurrentMode()
        self.animateViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func animateViews() {
        let springDuration = 0.5
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
        
        self.dappContainerSwipeableView.transform = CGAffineTransformConcat(scale, translate)
        self.dappContainerSwipeableView.alpha = 0.0
        
        spring(springDuration) {
            let scale = CGAffineTransformMakeScale(1.0, 1.0)
            let translate = CGAffineTransformMakeTranslation(0.0, 0.0)
            
            self.dappContainerSwipeableView.transform = CGAffineTransformConcat(scale, translate)
            self.dappContainerSwipeableView.alpha = 1.0
        }
        
        switch self.mode {
        case .ChooseColor, .ChooseFont:
            self.buttonsContainerViewsContainerView.alpha = 0.0
            self.buttonsContainerViewsContainerView.transform =
                CGAffineTransformMakeTranslation(0.0, 200.0)
            
            spring(springDuration) {
                self.buttonsContainerViewsContainerView.alpha = 1.0
                self.buttonsContainerViewsContainerView.transform =
                    CGAffineTransformMakeTranslation(0.0, 0.0)
            }
        case _:
            break
        }
        
        switch self.mode {
        case .ChooseColor:
            for (colorButton, _) in self.colorButtonsColorNames {
                colorButton.transform = CGAffineTransformMakeTranslation(0.0, 200.0)
            }
            
            springWithDelay(springDuration, delay: 0.02, animations: {
                for (colorButton, _) in self.colorButtonsColorNames {
                    colorButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                }
            })
        case .ChooseFont:
            for (fontButton, _) in self.fontButtonsFontNames {
                fontButton.transform = CGAffineTransformMakeTranslation(0.0, 200.0)
            }
            
            springWithDelay(springDuration, delay: 0.02, animations: {
                for (fontButton, _) in self.fontButtonsFontNames {
                    fontButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                }
            })
        case _:
            break
        }
    }
    
    private func initColorButtonsColors() {
        self.colorButtonsColorNames = [
            self.colorButtonLeftTop      : .Cinnabar,
            self.colorButtonMiddleTop    : .SummerSky,
            self.colorButtonRightTop     : .Saffron,
            self.colorButtonLeftMiddle   : .Cello,
            self.colorButtonMiddleMiddle : .MediumCarmine,
            self.colorButtonRightMiddle  : .MediumSeaGreen,
            self.colorButtonLeftBottom   : .LightSeaGreen,
            self.colorButtonMiddleBottom : .DeepLilac,
            self.colorButtonRightBottom  : .Gamboge
        ]
    }
    
    private func initFontButtonsFonts() {
        self.fontButtonsFontNames = [
            self.fontButtonLeftTop      : .Banksia,
            self.fontButtonMiddleTop    : .Bellota,
            self.fontButtonRightTop     : .CaptureIt,
            self.fontButtonLeftMiddle   : .Elsie,
            self.fontButtonMiddleMiddle : .Exo,
            self.fontButtonRightMiddle  : .KlinicSlab,
            self.fontButtonLeftBottom   : .PrintClearly,
            self.fontButtonMiddleBottom : .Sansation,
            self.fontButtonRightBottom  : .WalkwaySemiBold
        ]
    }
    
    @IBAction func applyColor(sender: AnyObject) {
        if let
            colorButton = sender as? UIButton,
            colorName = self.colorButtonsColorNames[colorButton] {
                self.dappColorName = colorName
                
                self.dappTextView.backgroundColor = DappColors.colorWithColorName(colorName)
                
                self.animateViews()
        }
    }
    
    @IBAction func applyFont(sender: AnyObject) {
        if let
            fontButton = sender as? UIButton,
            fontName = self.fontButtonsFontNames[fontButton] {
                let fontFileName = DappFonts.fontFileNameWithName(fontName)
                let font = UIFont(name: fontFileName, size: 25.0)
                
                self.dappTextView.font = font
                
                self.dappFontName = fontName
                
                self.animateViews()
        }
    }
    
    private func prepareViewsForCurrentMode() {
        switch self.mode {
        case .ChooseColor:
            self.dappTextView.editable = false
            self.dappContainerSwipeableView.hidden = false
            self.hashtagTextView.hidden = true
            self.buttonsContainerViewsContainerView.hidden = false
            self.colorButtonsContainerView.hidden = false
            self.fontButtonsContainerView.hidden = true
        case .AddText:
            self.dappTextView.editable = true
            self.dappContainerSwipeableView.hidden = false
            self.hashtagTextView.hidden = false
            self.buttonsContainerViewsContainerView.hidden = true
        case .ChooseFont:
            self.dappTextView.editable = false
            self.dappContainerSwipeableView.hidden = false
            self.hashtagTextView.hidden = true
            self.buttonsContainerViewsContainerView.hidden = false
            self.colorButtonsContainerView.hidden = true
            self.fontButtonsContainerView.hidden = false
        }
    }
    
    func getDapp() -> Dapp {
        let user                   = PFUser.currentUser()
        let dappStatement          = self.dappTextView.text
        let lowercaseDappStatement = self.dappTextView.text.lowercaseString
        let dappFont               = self.dappFontName.rawValue
        let dappBackgroundColor    = self.dappColorName.rawValue
        let name                   = user["name"] as? String
        let userid                 = user.objectId
        let dappScore              = 1
        let isDeleted              = false
        let dappTypeId             = DappTypeId.Secondary.rawValue
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
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
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
            switch self.mode {
            case .ChooseColor:
                self.mode = .AddText
                
                self.prepareViewsForCurrentMode()
                self.animateViews()
            case .AddText:
                self.mode = .ChooseFont
                
                self.prepareViewsForCurrentMode()
                self.animateViews()
            case .ChooseFont:
                self.performSegueWithIdentifier(self.showDappLinksSegueID, sender: self)
            }
        case .RightToLeft:
            switch self.mode {
            case .ChooseColor:
                self.dismissViewControllerAnimated(true, completion: nil)
            case .AddText:
                self.mode = .ChooseColor
                
                self.prepareViewsForCurrentMode()
                self.animateViews()
            case .ChooseFont:
                self.mode = .AddText
                
                self.prepareViewsForCurrentMode()
                self.animateViews()
            }
        }
    }
    
    func didSwipe(swipeDirection: SwipeDirection) {}
}

extension AddDappViewController: UITextViewDelegate {
    func textView(textView: UITextView,
                  shouldChangeTextInRange range: NSRange,
                  replacementText text: String) -> Bool {
        let newTextLength = textView.text.characters.count + text.characters.count - range.length
        let tweetMaxCharactersCount = 140
        
        if newTextLength > tweetMaxCharactersCount {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let prohibitedPhrases = ProhibitedPhrases.prohibitedPhrasesInString(textView.text)
        
        if prohibitedPhrases.count > 0 {
            self.prohibitedWordsLabel.hidden = false
            self.dappContainerSwipeableView.canBeDraged = false
            
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
            self.dappContainerSwipeableView.canBeDraged = true
        }
    }
}
