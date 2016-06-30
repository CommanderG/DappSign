//
//  AddDappViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

struct Dapp {
    var dappStatement          : String?
    var lowercaseDappStatement : String?
    var dappFont               : String?
    var dappBackgroundColor    : String?
    var name                   : String?
    var userid                 : String?
    var dappScore              : Int
    var isDeleted              : Bool
    var hashtagNames           : [String]
}

enum Mode {
    case ChooseColor
    case ChooseFont
    case AddText
}

class AddDappViewController: UIViewController {
    @IBOutlet weak var prohibitedWordsLabel               : UILabel!
    @IBOutlet weak var titleLabel                         : UILabel!
    @IBOutlet weak var dappMessageContainerSwipeableView  : SwipeableView!
    @IBOutlet weak var dappMessageTextView                : UITextView!
    @IBOutlet weak var hashtagsTextField                  : UITextField!
    @IBOutlet weak var buttonsContainerViewsContainerView : UIView!
    @IBOutlet weak var colorButtonsContainerView          : UIView!
    @IBOutlet weak var fontButtonsContainerView           : UIView!
    
    @IBOutlet weak var colorButtonLeftTop      : UIButton!
    @IBOutlet weak var colorButtonMiddleTop    : UIButton!
    @IBOutlet weak var colorButtonRightTop     : UIButton!
    @IBOutlet weak var colorButtonLeftMiddle   : UIButton!
    @IBOutlet weak var colorButtonMiddleMiddle : UIButton!
    @IBOutlet weak var colorButtonRightMiddle  : UIButton!
    @IBOutlet weak var colorButtonLeftBottom   : UIButton!
    @IBOutlet weak var colorButtonMiddleBottom : UIButton!
    @IBOutlet weak var colorButtonRightBottom  : UIButton!
    
    @IBOutlet weak var fontButtonLeftTop      : UIButton!
    @IBOutlet weak var fontButtonMiddleTop    : UIButton!
    @IBOutlet weak var fontButtonRightTop     : UIButton!
    @IBOutlet weak var fontButtonLeftMiddle   : UIButton!
    @IBOutlet weak var fontButtonMiddleMiddle : UIButton!
    @IBOutlet weak var fontButtonRightMiddle  : UIButton!
    @IBOutlet weak var fontButtonLeftBottom   : UIButton!
    @IBOutlet weak var fontButtonMiddleBottom : UIButton!
    @IBOutlet weak var fontButtonRightBottom  : UIButton!
    
    @IBOutlet weak var dappMessageContainerViewBottomConstraint: NSLayoutConstraint!
    
    private let showDappLinksSegueID: String = "showDappLinks"
    
    private var mode                   : Mode                  = .ChooseColor
    private var dappColorName          : ColorName             = .Cinnabar
    private var dappFontName           : FontName              = .Exo
    private var colorButtonsColorNames : [UIButton: ColorName] = [:]
    private var fontButtonsFontNames   : [UIButton: FontName]  = [:]
    private var nameString             : String!               = ""
    private var originalLocation       : CGPoint!              = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dappMessageTextView.editable = false
        
        // AddDappText Setup
        self.dappMessageTextView.delegate = self
        
        self.initHashtagsTextView()
        
        self.dappMessageContainerSwipeableView.appearanceDelegate = self
        self.dappMessageContainerSwipeableView.minTranslationX = 200.0
        
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
        
        self.dappMessageTextView.layer.cornerRadius = 10.0
        self.dappMessageTextView.layer.borderColor = UIColor.whiteColor().CGColor
        self.dappMessageTextView.layer.borderWidth = 2.0
        
        self.buttonsContainerViewsContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        self.buttonsContainerViewsContainerView.layer.borderWidth = 2.0
        
        self.dappMessageTextView.backgroundColor = DappColors.colorWithColorName(self.dappColorName)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dappMessageContainerSwipeableView.hidden = true
        self.hashtagsTextField.hidden = true
        self.buttonsContainerViewsContainerView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareViewsForCurrentMode()
        self.animateViews()
        self.dappMessageContainerSwipeableView.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func initHashtagsTextView() {
        if let placeholder = self.hashtagsTextField.placeholder {
            let blackColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            let placeholderAttributes = [NSForegroundColorAttributeName: blackColor]
            let attributedPlaceholder = NSAttributedString(string: placeholder,
                attributes: placeholderAttributes
            )
            
            self.hashtagsTextField.attributedPlaceholder = attributedPlaceholder
        }
        
        self.hashtagsTextField.layer.cornerRadius = 6.0
    }
    
    private func animateViews() {
        let springDuration = 0.5
        let springDelay = 0.02
        let translateTo0_0 = CGAffineTransformMakeTranslation(0.0, 0.0)
        let translateTo0_200 = CGAffineTransformMakeTranslation(0.0, 200.0)
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
        let transform = CGAffineTransformConcat(scale, translate)
        
        self.dappMessageContainerSwipeableView.transform = transform
        self.dappMessageContainerSwipeableView.alpha = 0.0
        
        spring(springDuration) {
            let scale = CGAffineTransformMakeScale(1.0, 1.0)
            let transform = CGAffineTransformConcat(scale, translateTo0_0)
            
            self.dappMessageContainerSwipeableView.transform = transform
            self.dappMessageContainerSwipeableView.alpha = 1.0
        }
        
        switch self.mode {
        case .ChooseColor, .ChooseFont:
            self.buttonsContainerViewsContainerView.alpha = 0.0
            self.buttonsContainerViewsContainerView.transform = translateTo0_200
            
            spring(springDuration) {
                self.buttonsContainerViewsContainerView.alpha = 1.0
                self.buttonsContainerViewsContainerView.transform = translateTo0_0
            }
        case _:
            break
        }
        
        switch self.mode {
        case .ChooseColor:
            for (colorButton, _) in self.colorButtonsColorNames {
                colorButton.transform = translateTo0_200
            }
            
            springWithDelay(springDuration, delay: springDelay, animations: {
                for (colorButton, _) in self.colorButtonsColorNames {
                    colorButton.transform = translateTo0_0
                }
            })
        case .ChooseFont:
            for (fontButton, _) in self.fontButtonsFontNames {
                fontButton.transform = translateTo0_200
            }
            
            springWithDelay(springDuration, delay: springDelay, animations: {
                for (fontButton, _) in self.fontButtonsFontNames {
                    fontButton.transform = translateTo0_0
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
    
    // MARK: - @IBActions
    
    @IBAction func applyColor(sender: AnyObject) {
        if let
            colorButton = sender as? UIButton,
            colorName = self.colorButtonsColorNames[colorButton] {
                self.dappColorName = colorName
                
                self.dappMessageTextView.backgroundColor = DappColors.colorWithColorName(colorName)
                
                self.animateViews()
        }
    }
    
    @IBAction func applyFont(sender: AnyObject) {
        if let
            fontButton = sender as? UIButton,
            fontName = self.fontButtonsFontNames[fontButton] {
                let fontFileName = DappFonts.fontFileNameWithName(fontName)
                let font = UIFont(name: fontFileName, size: 25.0)
                
                self.dappMessageTextView.font = font
                
                self.dappFontName = fontName
                
                self.animateViews()
        }
    }
    
    @IBAction func hashtagsTextFieldDidChange(sender: AnyObject) {
        if let text = self.hashtagsTextField.text {
            // automatically add # after user added a whitespace
            if text.characters.last == " " {
                self.hashtagsTextField.text = text + "#"
            }
        }
    }
    
    // MARK: -
    
    private func prepareViewsForCurrentMode() {
        switch self.mode {
        case .ChooseColor:
            self.titleLabel.text = "Choose a color."
            self.dappMessageTextView.editable = false
            self.dappMessageContainerSwipeableView.hidden = false
            self.hashtagsTextField.hidden = true
            self.buttonsContainerViewsContainerView.hidden = false
            self.colorButtonsContainerView.hidden = false
            self.fontButtonsContainerView.hidden = true
            
            self.dappMessageTextView.resignFirstResponder()
            self.hashtagsTextField.resignFirstResponder()
        case .AddText:
            self.titleLabel.text = "Choose your message."
            self.dappMessageTextView.editable = true
            self.dappMessageContainerSwipeableView.hidden = false
            self.hashtagsTextField.hidden = false
            self.buttonsContainerViewsContainerView.hidden = true
            
            self.dappMessageTextView.becomeFirstResponder()
        case .ChooseFont:
            self.titleLabel.text = "Choose a font."
            self.dappMessageTextView.editable = false
            self.dappMessageContainerSwipeableView.hidden = false
            self.hashtagsTextField.hidden = true
            self.buttonsContainerViewsContainerView.hidden = false
            self.colorButtonsContainerView.hidden = true
            self.fontButtonsContainerView.hidden = false
            
            self.dappMessageTextView.resignFirstResponder()
            self.hashtagsTextField.resignFirstResponder()
        }
    }
    
    private func getDapp() -> Dapp {
        let user                   = PFUser.currentUser()
        let dappStatement          = self.dappMessageTextView.text
        let lowercaseDappStatement = self.dappMessageTextView.text.lowercaseString
        let dappFont               = self.dappFontName.rawValue
        let dappBackgroundColor    = self.dappColorName.rawValue
        let name                   = user["name"] as? String
        let userid                 = user.objectId
        let dappScore              = 1
        let isDeleted              = false
        var hashtagNames: [String] = []
        
        if let hashtagsText = self.hashtagsTextField.text {
            hashtagNames = hashtagsText.characters.split(" ").map{ String($0) }
            hashtagNames = hashtagNames.map {
                // removes #
                $0[1...$0.characters.count - 1]
            }
        }
        
        let dapp = Dapp(
            dappStatement          :          dappStatement,
            lowercaseDappStatement : lowercaseDappStatement,
            dappFont               :               dappFont,
            dappBackgroundColor    :    dappBackgroundColor,
            name                   :                   name,
            userid                 :                 userid,
            dappScore              :              dappScore,
            isDeleted              :              isDeleted,
            hashtagNames           :           hashtagNames
        )
        
        return dapp
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.showDappLinksSegueID {
            let dapp = self.getDapp()
            let linksVC = segue.destinationViewController as? AddDappLinksVC
            
            linksVC?.dapp = dapp
            linksVC?.addDappVC = self
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
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if self.hashtagsTextField.text?.characters.count == 0 {
            textField.text = "#"
        }
        
        return true
    }
    
    func textField(
        textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String
    ) -> Bool {
        if let currText = textField.text as NSString? {
            let newText = currText.stringByReplacingCharactersInRange(range, withString: string)
            
            if currText.containsString(newText) {
                let removed = self.removeWhitespaceAndHashtagSymbol()
                
                if removed {
                    return false
                }
            }
            
            if newText.characters.count < 2 {
                if newText.characters.first == "#" {
                    return true
                }
                
                return false
            }
            
            if let _ = newText.rangeOfString("  ") {
                return false
            }
            
            if let _ = newText.rangeOfString("# ") {
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        let characters = self.hashtagsTextField.text?.characters
        
        if characters?.count == 1 && characters?.last == "#" {
            self.hashtagsTextField.text = ""
        } else {
            self.removeWhitespaceAndHashtagSymbol()
        }
    }
    
    // MARK: -
    
    private func removeWhitespaceAndHashtagSymbol() -> Bool {
        guard let text = self.hashtagsTextField.text else {
            return false
        }
        
        if text.characters.count < 2 {
            return false
        }
        
        let twoLastSymbols = String(text.characters.suffix(2))
        
        if twoLastSymbols == " #" {
            let startIndex = text.startIndex
            let endIndex = text.endIndex.predecessor().predecessor()
            
            self.hashtagsTextField.text = text[startIndex ..< endIndex]
            
            return true
        }
        
        return false
    }
}

extension AddDappViewController: SwipeableViewAppearanceDelegate {
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
            self.dappMessageContainerSwipeableView.canBeDraged = false
            
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
            self.dappMessageContainerSwipeableView.canBeDraged = true
        }
    }
}
