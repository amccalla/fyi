//
//  UIViewControllerUtility.swift
//  FYI
//
//  Created by Andrew McCalla on 12/6/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit

extension UIViewController {

    //Convenience method to set the root of the window to the
    //specified view controller
    //
    class func setWindowRootViewController(_ storyboardName: String, storyboardID: String?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewController = getViewControllerFromStoryboard(storyboardName, storyboardID: storyboardID)
        appDelegate.window?.rootViewController = viewController
    }

    //Convenience method to push a view controller onto
    //a navigation controller
    //
    class func pushViewController(_ navigationController: UINavigationController, storyboardName: String, storyboardID: String?) {
        let viewController = getViewControllerFromStoryboard(storyboardName, storyboardID: storyboardID)

        if let vc = viewController {
            navigationController.pushViewController(vc, animated: true)
        }
    }

    //Convenience method to get a specific view controller from
    //a given storyboard with an identifier
    //
    class func getViewControllerFromStoryboard(_ storyboardName: String, storyboardID: String?) -> UIViewController? {
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)

        if let id = storyboardID {
            return storyboard.instantiateViewController(withIdentifier: id)
        } else {
            return storyboard.instantiateInitialViewController()
        }
    }
    
    // Show Alert controller (pop up) with given message and has only one button to dismiss
    //
    func showAlertWith(_ message: String, title: String, phone: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        
        // add another option in alert view for calling if phone number is available
        //
        if let phoneNumber = phone {
            let callAction = UIAlertAction(title: "Call", style: UIAlertActionStyle.default, handler: { (action) in
                if let callUrl = URL(string: "tel://" + phoneNumber) {
                    UIApplication.shared.openURL(callUrl)
                }
            })
            alertController.addAction(callAction)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
