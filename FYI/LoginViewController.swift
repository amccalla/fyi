//
//  LoginViewController.swift
//  FYI
//
//  Created by Andrew McCalla on 12/6/16.
//  Copyright © 2016 McCalla Apps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import ObjectMapper
import RealmSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextfield: UITextField!

    var dbUserSearch: FIRDatabaseReference!
    var dbUsers: FIRDatabaseReference!
    
    var usernames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUserSearch = FIRDatabase.database().reference().child("users/\(UserDefaults.standard.value(forKey: "playerId") ?? "")")
        dbUsers = FIRDatabase.database().reference().child("users")
        getUsernames()
        userNameTextfield.delegate = self
    }

    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    func getUsernames() {
        dbUsers.observeSingleEvent(of: .value, with: { snapshot in
            for users in snapshot.children {
                let user = users as? FIRDataSnapshot
                let dict = user?.value as? Dictionary<String, Any>
                guard let dt = dict, let username = dt["username"] as? String else { continue }
                self.usernames.append(username)
            }
        })
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let realm = try! Realm()
        
        if let userName = userNameTextfield.text, userNameTextfield.text != "" {
            dbUserSearch.observeSingleEvent(of: .value, with: { snapshot in
                if let profile = snapshot.value as? [String: Any] {
                    let mappedProfile = Mapper<Profile>().map(JSON: profile)
                    
                    if mappedProfile?.username != userName {
                        self.showAlertWith("Incorrect Username", title: "Login Error")
                        return
                    }
                    
                    guard let user = mappedProfile else {
                        self.showAlertWith("Unable to fetch profile from server", title: "Error")
                        return
                    }
                    try! realm.write {
                        realm.add(user)
                    }
                    
                    UserDefaults.standard.setValue(true, forKey: "loggedIn")
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                } else {
                    self.setupNewProfile(name: userName)
                }
            })
            setupNewProfile(name: userName)
        } else {
            showAlertWith("Please enter a username", title: "Login Error")
        }
    }
    
    func setupNewProfile(name: String) {
        let newProfile = self.dbUsers.ref.child(UserDefaults.standard.string(forKey: "playerId") ?? "")
        
        if usernames.contains(name) {
            showAlertWith("Username taken", title: "Login Error")
            return
        }
        
        let userDict = ["username": name, "playerId": UserDefaults.standard.string(forKey: "playerId") ?? "", "friends": ""]
        newProfile.setValue(userDict)
        
        let realm = try! Realm()
        let profile = Profile()
        
        profile.username = name
        profile.playerId = UserDefaults.standard.string(forKey: "playerId")
        profile.friends = List<Friend>()
        
        try! realm.write {
            realm.add(profile)
        }
        
        UserDefaults.standard.setValue(true, forKey: "loggedIn")
        self.performSegue(withIdentifier: "loginSuccess", sender: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let limitLength = 15
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
}
