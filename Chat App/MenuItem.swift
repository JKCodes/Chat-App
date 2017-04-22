//
//  MenuItem.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

enum MenuItemName: String {
    case profile = "PROFILE"
    case help = "HELP"
    case notification = "NOTIFICATIONS"
    case settings = "SETTINGS"
    case logout = "LOGOUT"
    case cancel = "CANCEL"
}

class MenuItem: NSObject {
    let name: MenuItemName
    let image: UIImage
    
    init(name: MenuItemName, image: UIImage) {
        self.name = name
        self.image = image
    }
}
