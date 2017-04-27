//
//  Message.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var timestamp: String?
    
    var text: String?
    
    func chatPartnerId() -> String? {
        return fromId == AuthenticationService.shared.currentId() ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? String
        toId = dictionary["toId"] as? String
    }
}
