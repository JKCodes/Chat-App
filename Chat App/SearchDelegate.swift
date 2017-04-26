//
//  SearchDelegate.swift
//  Chat App
//
//  Created by Joseph Kim on 4/25/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol SearchDelegate: class {
    func addRemoveFriend(user: User)
    func isFriend(user: User, onComplete: @escaping (Bool) -> Void)
}
