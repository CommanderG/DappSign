//
//  EmbedDappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol EmbedDappDelegate {
    func didRemoveFromParentViewController()
}

class EmbedDappVC: UIViewController {
    @IBOutlet weak var dappURLLabel:                    UILabel!
    @IBOutlet weak var dappURLLabelContainerView:       UIView!
    @IBOutlet weak var iframeCodeTextView:              UITextView!
    @IBOutlet weak var iframeCodeTextViewContainerView: UIView!
    @IBOutlet weak var doneButton:                      UIButton!
    
    internal var delegate: EmbedDappDelegate? = nil
    
    private var hideWithAnimation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
        self.view.layer.cornerRadius = 20.0
        
        self.dappURLLabelContainerView.layer.cornerRadius = 8.0
        self.iframeCodeTextViewContainerView.layer.cornerRadius = 8.0
        self.doneButton.layer.cornerRadius = 8.0
        
        self.dappURLLabelContainerView.backgroundColor = Colors.getLightBlueColor()
        self.iframeCodeTextViewContainerView.backgroundColor = Colors.getLightBlueColor()
        self.doneButton.backgroundColor = Colors.getLightBlueColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    
    internal func showURLAndIFrameCodeForDappWithID(dappID: String) {
        self.dappURLLabel.text = "http://dappsign.com/?petition_id=\(dappID)"
        self.iframeCodeTextView.text = "<iframe width=\"260\" height=\"420\" " +
                                       "src=\"http://www.dappsign.com/embed/?petition_id=\(dappID)\" " +
                                       "frameborder=\"0\"></iframe>"
    }
    
    internal func frameWithDappViewFrame(dappViewFrame: CGRect) -> CGRect {
        let dx: CGFloat = 1.5
        
        var frame = dappViewFrame
        
        frame.origin.x -= dx
        frame.origin.y += 16.0
        frame.size.width += dx * 2
        frame.size.height -= 58.0
        
        return frame
    }
    
    internal func show() {
        self.hideWithAnimation = true
        
        AnimationHelper.showView(self.view)
    }
    
    // MARK: - IBAction
    
    @IBAction func copyDappURL() {
        if let link = self.dappURLLabel.text {
            let pasteboard = UIPasteboard.generalPasteboard()
            
            pasteboard.string = link
            
            self.showHUDWithTextCopiedToClipboard()
        }
    }
    
    @IBAction func copyIFrameCode() {
        if let iframeCode = self.iframeCodeTextView.text {
            let pasteboard = UIPasteboard.generalPasteboard()
            
            pasteboard.string = iframeCode
            
            self.showHUDWithTextCopiedToClipboard()
        }
    }
    
    @IBAction func done() {
        if self.hideWithAnimation {
            AnimationHelper.hideView(self.view) {
                self.hide()
            }
        } else {
            self.hide()
        }
    }
    
    // MARK: -
    
    private func hide() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        self.delegate?.didRemoveFromParentViewController()
    }
    
    private func showHUDWithTextCopiedToClipboard() {
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        progressHUD.mode = MBProgressHUDMode.Text
        progressHUD.labelText = "Copied to clipboard"
        
        delay(0.75) {
            progressHUD.hide(true)
        }
    }
}
