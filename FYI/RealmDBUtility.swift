//
//  RealmDBUtility.swift
//  FYI
//
//  Created by Andrew McCalla on 12/24/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDBUtility {
    
    let realm = try! Realm()
    static let sharedInstance = RealmDBUtility()
    
    func profileFetcher() -> Profile? {
        let profile = realm.objects(Profile.self).first
        return profile ?? nil
    }
    
    func updateProfile(updatedProfile: Profile) {
        var profile = realm.objects(Profile.self).first
        try! realm.write {
            profile = updatedProfile
        }
    }
}
