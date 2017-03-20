//
//  LoginService.swift
//  FYI
//
//  Created by Andrew McCalla on 12/24/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import RealmSwift

protocol LoginServiceCompletionHandler {
    func handleSuccessWith(userProfile: Profile)
    func handleErrorWith(message: String)
}

class LoginService: BaseRestClientService {
    
    var completionHandler: LoginServiceCompletionHandler?
    var userId = ""
    
    init(handler: LoginServiceCompletionHandler) {
        completionHandler = handler
    }
    
    func loginWith(uid: String) {
        userId = uid
        getRequest().responseObject { (response: DataResponse<Profile>) -> Void in
            if let profile = response.result.value {
                self.completionHandler?.handleSuccessWith(userProfile: profile)
            } else {
                self.completionHandler?.handleErrorWith(message: response.result.error as! String)
            }
        }
    }
    
    override func resourcePath() -> String {
        return "users/\(userId)"
    }
}
