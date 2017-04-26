//
//  SearchController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/24/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, SearchDelegate, Alerter {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 80
    fileprivate let contentSpacing: CGFloat = 8
    fileprivate let searchBarleftSpacing: CGFloat = 100
    
    fileprivate let window = UIApplication.shared.keyWindow
    fileprivate let currentUserId = AuthenticationService.shared.currentId()
    
    lazy var searchBar: UISearchBar = { [weak self] in
        guard let this = self else { return UISearchBar() }
        let sb = UISearchBar()
        sb.placeholder = "Enter username or name"
        sb.barTintColor = .white
        sb.delegate = this
        sb.autocapitalizationType = .none
        return sb
    }()
    
    fileprivate var filteredUsers = [User]()
    fileprivate var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white

        navigationController?.navigationBar.addSubview(searchBar)

        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: searchBarleftSpacing, bottomConstant: 0, rightConstant: contentSpacing, widthConstant: 0, heightConstant: 0)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        collectionView?.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchUsers()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        cell.delegate = self
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        addRemoveFriend(user: user)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { (user) -> Bool in
                return (user.username.lowercased().contains(searchText.lowercased())) || (user.firstName.lowercased().contains(searchText.lowercased())) || (user.lastName.lowercased().contains(searchText.lowercased()))
            }
        }
        collectionView?.reloadData()
    }
}

extension SearchController {
    
    fileprivate func fetchUsers() {
        guard let uid = currentUserId else { return }
        
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: nil, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                if key == uid {
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else { return }
                
                let user = User(uid: key, dictionary: userDictionary)
                this.users.append(user)
            })
            
            this.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            this.filteredUsers = this.users
            this.collectionView?.reloadData()
        }
    }
    
    
    func addRemoveFriend(user: User) {
        
        isFriend(user: user, onComplete: { [weak self] (isFriend) in
            guard let this = self else { return }
            if isFriend {
                this.removeFriend(user: user, onComplete: { (completed) in
                    if !completed {
                        return
                    }
                })
            } else {
                this.addFriend(user: user, onComplete: { (completed) in
                    if !completed {
                        return
                    }
                })
            }
            this.collectionView?.reloadData()
        })
    }
    
    fileprivate func addFriend(user: User, onComplete: @escaping (Bool) -> Void) {
        guard let uid = currentUserId else { return }
        let values = [user.uid: 1] as [String: AnyObject]
        DatabaseService.shared.saveData(type: .following, data: values, firstChild: uid, secondChild: nil, appendAutoId: false) { [weak self] (error, _) in
            guard let this = self else { return }
            if error != nil {
                this.present(this.alertVC(title: "Error saving data", message: "An unexpected error has occurred while adding a friend. Please try again."), animated: true, completion: nil)
                onComplete(false)
            }
            onComplete(true)
        }
    }
    
    fileprivate func removeFriend(user: User, onComplete: @escaping (Bool) -> Void) {
        guard let uid = currentUserId else { return }
        
        DatabaseService.shared.remove(type: .following, firstChild: uid, secondChild: user.uid) { [weak self] (error, _) in
            guard let this = self else { return }
            if error != nil {
                this.present(this.alertVC(title: "Error saving data", message: "An unexpected error has occurred while removing a friend. Please try again."), animated: true, completion: nil)
                onComplete(false)
            }
            onComplete(true)
        }
        
    }
    
    func isFriend(user: User, onComplete: @escaping (Bool) -> Void) {
        guard let uid = currentUserId else { return }
        
        DatabaseService.shared.retrieveOnce(type: .following, eventType: .value, firstChild: uid, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
            if snapshot.hasChild(user.uid) {
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
    }
    
}
