//
//  DatabaseService + fetchUsers.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

extension DatabaseService {
    
    func fetchUsers(onComplete: @escaping ([User]) -> Void) {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        var users = [User]()
        
        retrieveOnce(type: .user, eventType: .value, firstChild: nil, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                if key == uid {
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else { return }
                
                let user = User(uid: key, dictionary: userDictionary)
                users.append(user)
            })
            
            users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            onComplete(users)
        }
    }
    
    func fetchFollowingUsers(onComplete: @escaping ([User]) -> Void) {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        var users = [User]()

        // Counter is used to see how many User instances has been created and appended
        var counter = 0
        
        retrieveOnce(type: .following, eventType: .value, firstChild: uid, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
            guard let usersDictionary = snapshot.value as? [String: Int] else { return }
                        
            usersDictionary.forEach({ (key, value) in
                DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: key, secondChild: nil, propagate: nil, sortBy: nil, onComplete: { (snapshot) in
                    guard let userDictionary = snapshot.value as? [String: Any] else { return }
                    
                    let user = User(uid: key, dictionary: userDictionary)
                    users.append(user)
                    
                    // Increase the counter by one. Note that the finish order does not matter - i.e. second call to Firebase can finish before first call and etc.
                    counter += 1
                    
                    if counter == usersDictionary.count {
                        users.sort(by: { (u1, u2) -> Bool in
                            return u1.username.compare(u2.username) == .orderedAscending
                        })
                        onComplete(users)
                    }
                })
            
            })
        }
    }
}
