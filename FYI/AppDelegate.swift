//
//  AppDelegate.swift
//  FYI
//
//  Created by Andrew McCalla on 12/6/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import OneSignal
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var token = ""
    
    var dbUserSearch: FIRDatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "31a86b36-2bcd-49ac-abb0-1fdb3f2a58cb", handleNotificationAction: nil, settings: [kOSSettingsKeyInFocusDisplayOption: OSNotificationDisplayType.none.rawValue, kOSSettingsKeyAutoPrompt: true])
        
        OneSignal.idsAvailable({ (userId, pushToken) in
            UserDefaults.standard.setValue(userId, forKey: "playerId")
            self.dbUserSearch = FIRDatabase.database().reference().child("users/\(UserDefaults.standard.value(forKey: "playerId") ?? "")")
            self.checkForExistingProfile()
        })
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func checkForExistingProfile() {
        dbUserSearch.observeSingleEvent(of: .value, with: { snapshot in
            if let profile = snapshot.value as? [String: Any] {
                UIViewController.setWindowRootViewController("Friends", storyboardID: nil)
            } else {
                UIViewController.setWindowRootViewController("Main", storyboardID: nil)
            }
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
}
