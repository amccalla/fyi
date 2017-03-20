//
//  HandleFIRErrorCodes.swift
//  FYI
//
//  Created by Andrew McCalla on 12/13/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class HandleFIRErrorCodes {
    
    static let sharedInstance = HandleFIRErrorCodes()
    
    func errorCodeAlerts(error: NSError) -> String {
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .errorCodeUserNotFound:
                return "User does not exist"
            case .errorCodeEmailAlreadyInUse:
                return "Email is already in use"
            case .errorCodeWrongPassword:
                return "Incorrect password"
            case .errorCodeInvalidEmail:
                return "Invalid email"
            default:
                return "There was an issue completing your request. Please try again later"
            }
        } else {
            return "There was an issue completing your request. Please try again later"
        }
    }
}

