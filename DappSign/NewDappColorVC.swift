//
//  NewDappColorVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 7/3/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class NewDappColorVC: UIViewController {
    @IBOutlet weak var dappMessageContainer      : SwipeableView!
    @IBOutlet weak var dappMessageTextView       : UITextView!
    @IBOutlet weak var buttonsContainerView      : UIView!
    @IBOutlet weak var colorButtonsContainerView : UIView!
    
    @IBOutlet weak var colorButtonLeftTop      : UIButton!
    @IBOutlet weak var colorButtonMiddleTop    : UIButton!
    @IBOutlet weak var colorButtonRightTop     : UIButton!
    @IBOutlet weak var colorButtonLeftMiddle   : UIButton!
    @IBOutlet weak var colorButtonMiddleMiddle : UIButton!
    @IBOutlet weak var colorButtonRightMiddle  : UIButton!
    @IBOutlet weak var colorButtonLeftBottom   : UIButton!
    @IBOutlet weak var colorButtonMiddleBottom : UIButton!
    @IBOutlet weak var colorButtonRightBottom  : UIButton!
    
    private var colorButtonsColorNames: [UIButton: ColorName] = [:]
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        NewDappParams.setDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        self.dappMessageContainer.appearanceDelegate = self
        self.dappMessageContainer.minTranslationX = 200.0
        
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
        
        for (colorButton, colorName) in self.colorButtonsColorNames {
            NewDappViewsHelper.initButton(colorButton)
            colorButton.backgroundColor = DappColors.colorWithColorName(colorName)
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
    
    private func animateViews() {
        let colorButtons = Array(self.colorButtonsColorNames.keys)
        
        NewDappViewsHelper.animateDappMessageContainer(self.dappMessageContainer, completion: nil)
        NewDappViewsHelper.animateButtonsContainerView(self.buttonsContainerView)
        NewDappViewsHelper.animateButtons(colorButtons)
    }
    
    // MARK: - @IBActions
    
    @IBAction func applyColor(sender: AnyObject) {
        guard let colorButton = sender as? UIButton else {
            return
        }
        
        guard let colorName = self.colorButtonsColorNames[colorButton] else {
            return
        }
        
        NewDappParams.colorName = colorName
        
        NewDappViewsHelper.updateDappMessageTextView(self.dappMessageTextView)
        self.animateViews()
    }
}

extension NewDappColorVC: SwipeableViewAppearanceDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .LeftToRight:
            self.performSegueWithIdentifier("chooseYourMessage", sender: self)
            
            break
        case .RightToLeft:
            self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
            
            break
        }
    }
}
