//
//  Friend.swift
//  FYI
//
//  Created by Andrew McCalla on 12/21/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Friend: Object, Mappable {
    
    dynamic var username: String?
    dynamic var playerId: String?
    dynamic var nickname: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        playerId <- map["playerId"]
    }
}
