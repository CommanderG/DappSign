//
//  UIViewControllerAlertViewExtension.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/11/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import Foundation

extension UIViewController {
    func showAlertViewWithOKButtonAndMessage(message: String) -> Void {
        UIAlertView(
            title: nil,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK").show()
    }
}
