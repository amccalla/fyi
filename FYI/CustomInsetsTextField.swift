//
//  CustomInsetsTextField.swift
//  FYI
//
//  Created by Andrew McCalla on 12/25/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

// This is a custom text field with custom insets which can be configurable from inspector
//
@IBDesignable
class CustomInsetsTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0.0
    @IBInspectable var insetY: CGFloat = 0.0
    @IBInspectable var actionPerform: Bool = true
    
    // updated bounds from inspector values
    //
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    //If action perform is false, it prevents the user from being
    //able to paste/cut/copy in the textfield
    //
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if actionPerform {
            return super.canPerformAction(action, withSender: sender)
        } else {
            return false
        }
    }
}

