//
//  Profile.swift
//  FYI
//
//  Created by Andrew McCalla on 12/21/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Profile: Object, Mappable {
    
    dynamic var username: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var email: String?
    dynamic var userId: String?
    dynamic var playerId: String?
    
    var friends = List<Friend>()
    
    required convenience init?(map: Map) {
        self.init()
    }
        
    func mapping(map: Map) {
        username <- map["username"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        email <- map["email"]
        userId <- map["userId"]
        playerId <- map["playerId"]
        
        var friendsDict: [[String: String]]? = nil
        friendsDict <- map["friends"]
        
        if let dict = friendsDict {
            for friend in dict {
                let newFriend = Friend()
                newFriend.username = friend["username"]
                newFriend.playerId = friend["playerId"]
                friends.append(newFriend)
            }
        }
    }    
}
