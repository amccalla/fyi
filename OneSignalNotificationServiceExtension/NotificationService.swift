//
//  NotificationService.swift
//  OneSignalNotificationServiceExtension
//
//  Created by Andrew McCalla on 3/11/17.
//  Copyright © 2017 McCalla Apps. All rights reserved.
//

import UserNotifications
import OneSignal

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var recievedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.recievedRequest = request;
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignal.didReceiveNotificatioExtensionnRequest(self.recievedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.recievedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
