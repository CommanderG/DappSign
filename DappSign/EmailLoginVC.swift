//
//  EmailLoginVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/19/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol EmailLoginDelegate {
    func didRegister()
    func didSignIn()
}

class EmailLoginVC: UIViewController {
    @IBOutlet weak var segmentedControl  : UISegmentedControl!
    @IBOutlet weak var fullNameTextField : UITextField!
    @IBOutlet weak var emailTextField    : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    @IBOutlet weak var registerButton    : UIButton!
    @IBOutlet weak var logInButton       : UIButton!
    
    internal var delegate: EmailLoginDelegate? = nil
    
    private var user: PFUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBActions
    
    @IBAction func handleSegmentedControlValueChange() {
        self.initUI()
    }
    
    @IBAction func register() {
        guard
            let fullName = self.fullNameTextField.text,
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text
            else { return; }
        
        let fullName_ = self.stringWithRemoveLeadingAndTrailingWhitespacesInString(fullName)
        
        if fullName_.characters.count == 0 {
            showAlertViewWithOKButtonAndMessage("Please enter your full name")
            self.fullNameTextField.becomeFirstResponder()
            
            return
        }
        
        let email_ = self.stringWithRemoveLeadingAndTrailingWhitespacesInString(email)
        
        if email_.characters.count == 0 {
            showAlertViewWithOKButtonAndMessage("Please enter your email")
            self.emailTextField.becomeFirstResponder()
            
            return
        }
        
        let password_ = self.stringWithRemoveLeadingAndTrailingWhitespacesInString(password)
        
        if password_.characters.count == 0 {
            showAlertViewWithOKButtonAndMessage("Please enter your password")
            self.passwordTextField.becomeFirstResponder()
            
            return
        }
        
        PFUser.logOut()
        
        let user = PFUser()
        
        user.username = email_
        user.password = password_
        user["dappScore"] = 0
        user["name"] = fullName_
        user["lowercaseName"] = fullName_.lowercaseString
        
        user.signUpInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                self.dismissOrShowTermsForUser(user)
            } else if let error = error, errorString = error.userInfo["error"] as? String {
                if error.domain == "Parse" && error.code == 202 {
                    let emailErrorString =
                    errorString.stringByReplacingOccurrencesOfString("username",
                        withString: "Email"
                    ).stringByReplacingOccurrencesOfString("already",
                        withString: "is already"
                    )
                    
                    self.showAlertViewWithOKButtonAndMessage(emailErrorString)
                } else {
                    self.showAlertViewWithOKButtonAndMessage(errorString)
                }
            } else {
                self.showAlertViewWithOKButtonAndMessage("Unknown error")
            }
        }
    }
    
    @IBAction func logIn() {
        guard let email = self.emailTextField.text, password = self.passwordTextField.text else {
            return;
        }
        
        let email_ = self.stringWithRemoveLeadingAndTrailingWhitespacesInString(email)
        
        if email_.characters.count == 0 {
            showAlertViewWithOKButtonAndMessage("Please enter your email")
            self.emailTextField.becomeFirstResponder()
            
            return
        }
        
        let password_ = self.stringWithRemoveLeadingAndTrailingWhitespacesInString(password)
        
        if password_.characters.count == 0 {
            showAlertViewWithOKButtonAndMessage("Please enter your password")
            self.passwordTextField.becomeFirstResponder()
            
            return
        }
        
        PFUser.logOut()
        PFUser.logInWithUsernameInBackground(email_, password: password_, block: {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.dismissOrShowTermsForUser(user)
            } else if let errorString = error?.userInfo["error"] as? String {
                self.showAlertViewWithOKButtonAndMessage(errorString)
            } else {
                self.showAlertViewWithOKButtonAndMessage("Unknown error")
            }
        })
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - 
    
    private func dismissOrShowTermsForUser(user: PFUser) {
        self.user = user
        
        if user.isNew {
            TermsHelper.showAlertViewWithDelegate(self)
        } else {
            if TermsHelper.userAgreedToTerms(user) {
                self.dismiss()
            } else {
                TermsHelper.showAlertViewWithDelegate(self)
            }
        }
    }
    
    private func dismiss() {
        guard let user = self.user else {
            return
        }
        
        self.dismissViewControllerAnimated(true, completion: {
            if user.isNew {
                self.delegate?.didRegister()
            } else {
                self.delegate?.didSignIn()
            }
        })
    }
    
    // MARK: - UI
    
    private func initUI() {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.fullNameTextField.hidden = false
            self.logInButton.hidden = true
            self.registerButton.hidden = false
        } else {
            self.fullNameTextField.hidden = true
            self.logInButton.hidden = false
            self.registerButton.hidden = true
            
            if self.fullNameTextField.isFirstResponder() {
                self.fullNameTextField.resignFirstResponder()
            }
        }
    }
    
    // MARK: -
    
    private func stringWithRemoveLeadingAndTrailingWhitespacesInString(string: String) -> String {
        let whitespaceCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmedString = string.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        return trimmedString
    }
}

extension EmailLoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.fullNameTextField {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.passwordTextField.resignFirstResponder()
            
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.register()
            } else {
                self.logIn()
            }
        }
        
        return true
    }
}

extension EmailLoginVC: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        guard let user = self.user else {
            return
        }
        
        TermsHelper.handleAlertView(
            alertView,
            clickedButtonAtIndex: buttonIndex,
            viewController: self,
            user: user
        ) {
            (agreed: Bool) in
            if agreed {
                self.dismiss()
            } else if user.isNew {
                self.segmentedControl.selectedSegmentIndex = 1
                
                self.handleSegmentedControlValueChange()
            }
        }
    }
}
