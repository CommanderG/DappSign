//
//  NewDappMessageVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class NewDappMessageVC: UIViewController {
    @IBOutlet weak var prohibitedWordsLabel : UILabel!
    @IBOutlet weak var dappMessageContainer : SwipeableView!
    @IBOutlet weak var dappMessageTextView  : UITextView!
    @IBOutlet weak var hashtagsTextField    : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        self.dappMessageTextView.delegate = self
        
        self.initHashtagsTextView()
        
        self.dappMessageContainer.appearanceDelegate = self
        self.dappMessageContainer.minTranslationX = 200.0
        
        self.prohibitedWordsLabel.hidden = true
        
        NewDappViewsHelper.initDappMessageTextView(self.dappMessageTextView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NewDappViewsHelper.updateDappMessageTextView(self.dappMessageTextView)
        
        self.hashtagsTextField.text = NewDappParams.hashtags
        
        self.dappMessageContainer.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NewDappViewsHelper.animateDappMessageContainer(self.dappMessageContainer) {
            self.dappMessageTextView.becomeFirstResponder()
        }
        self.dappMessageContainer.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func initHashtagsTextView() {
        if let placeholder = self.hashtagsTextField.placeholder {
            let blackColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            let placeholderAttributes = [NSForegroundColorAttributeName: blackColor]
            let attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: placeholderAttributes
            )
            
            self.hashtagsTextField.attributedPlaceholder = attributedPlaceholder
        }
        
        self.hashtagsTextField.layer.cornerRadius = 6.0
    }
    
    // MARK: - @IBActions
    
    @IBAction func hashtagsTextFieldDidChange(sender: AnyObject) {
        if let text = self.hashtagsTextField.text {
            // automatically add # after user added a whitespace
            if text.characters.last == " " {
                self.hashtagsTextField.text = text + "#"
            }
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

extension NewDappMessageVC: UITextFieldDelegate {
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
        guard let currText = textField.text as NSString? else {
            return true
        }
        
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
        
        NewDappParams.hashtags = newText
        
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

extension NewDappMessageVC: SwipeableViewAppearanceDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            self.performSegueWithIdentifier("chooseFont", sender: self)
            
            break
        case .RightToLeft:
            self.navigationController?.popViewControllerAnimated(false)
            
            break
        }
    }
}

extension NewDappMessageVC: UITextViewDelegate {
    func textView(
        textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String
    ) -> Bool {
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
            self.dappMessageContainer.canBeDraged = false
            
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
            self.dappMessageContainer.canBeDraged = true
            
            NewDappParams.message = self.dappMessageTextView.text
        }
    }
}
