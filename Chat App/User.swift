//
//  User.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class User: NSObject {
    var firstName: String
    var lastName: String
    var email: String
    var username: String
    var profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
