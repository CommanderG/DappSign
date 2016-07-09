//
//  NewDappFontVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class NewDappFontVC: UIViewController {
    @IBOutlet weak var dappMessageContainer     : SwipeableView!
    @IBOutlet weak var dappMessageTextView      : UITextView!
    @IBOutlet weak var buttonsContainerView     : UIView!
    @IBOutlet weak var fontButtonsContainerView : UIView!
    
    @IBOutlet weak var fontButtonLeftTop      : UIButton!
    @IBOutlet weak var fontButtonMiddleTop    : UIButton!
    @IBOutlet weak var fontButtonRightTop     : UIButton!
    @IBOutlet weak var fontButtonLeftMiddle   : UIButton!
    @IBOutlet weak var fontButtonMiddleMiddle : UIButton!
    @IBOutlet weak var fontButtonRightMiddle  : UIButton!
    @IBOutlet weak var fontButtonLeftBottom   : UIButton!
    @IBOutlet weak var fontButtonMiddleBottom : UIButton!
    @IBOutlet weak var fontButtonRightBottom  : UIButton!
    
    private var fontButtonsFontNames: [UIButton: FontName] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dappMessageContainer.appearanceDelegate = self
        self.dappMessageContainer.minTranslationX = 200.0
        
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
        
        for (fontButton, fontName) in self.fontButtonsFontNames {
            NewDappViewsHelper.initButton(fontButton)
            fontButton.backgroundColor = UIColor.clearColor()
            
            let fontFileName = DappFonts.fontFileNameWithName(fontName)
            
            fontButton.titleLabel?.font = UIFont(name: fontFileName, size: 18.0)
            
            let title = DappFonts.fontDisplayNameWithFontName(fontName)
            
            fontButton.setTitle(title, forState: .Normal)
        }
        
        NewDappViewsHelper.initDappMessageTextView(self.dappMessageTextView)
        NewDappViewsHelper.initButtonsContainerView(self.buttonsContainerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NewDappViewsHelper.updateDappMessageTextView(self.dappMessageTextView)
        
        self.dappMessageContainer.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.animateViews()
        self.dappMessageContainer.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: -
    
    private func animateViews() {
        let fontButtons = Array(self.fontButtonsFontNames.keys)
        
        NewDappViewsHelper.animateDappMessageContainer(self.dappMessageContainer, completion: nil)
        NewDappViewsHelper.animateButtonsContainerView(self.buttonsContainerView)
        NewDappViewsHelper.animateButtons(fontButtons)
    }
    
    // MARK: - @IBActions
    
    @IBAction func applyFont(sender: AnyObject) {
        guard let fontButton = sender as? UIButton else {
            return
        }
        
        guard let fontName = self.fontButtonsFontNames[fontButton] else {
            return
        }
        
        NewDappParams.fontName = fontName
        
        NewDappViewsHelper.updateDappMessageTextView(self.dappMessageTextView)
        self.animateViews()
    }
    
    // MARK: - segua
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let addDappLinksVC = segue.destinationViewController as? AddDappLinksVC else {
            return
        }
        
        addDappLinksVC.dapp = NewDappHelper.getNewDapp()
    }
}

extension NewDappFontVC: SwipeableViewAppearanceDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            self.performSegueWithIdentifier("addLinks", sender: self)
            
            break
        case .RightToLeft:
            self.navigationController?.popViewControllerAnimated(false)
            
            break
        }
    }
}
