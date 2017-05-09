//
//  SettingsItem.swift
//  Chat App
//
//  Created by Joseph Kim on 5/8/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

enum SettingsName: String {
    case accountPrivacy = "Make me searchable by those who know my exact username only"
    case hideFromDefaultSearch = "Exclude me from search when search bar is empty"
    case pushNotifications = "Disable push notifications"
}

class SettingsItem: NSObject {
    let name: SettingsName
    var enabled: Bool
    
    init(name: SettingsName, enabled: Bool) {
        self.name = name
        self.enabled = enabled
    }
}
