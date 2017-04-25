//
//  SearchController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/24/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 80
    fileprivate let contentSpacing: CGFloat = 8
    fileprivate let searchBarleftSpacing: CGFloat = 100
    
    fileprivate let window = UIApplication.shared.keyWindow
    
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
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
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
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: nil, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                if key == uid {
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else { return }
                
                let user = User(dictionary: userDictionary)
                this.users.append(user)
            })
            
            this.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            this.filteredUsers = this.users
            this.collectionView?.reloadData()
        }
    }
    
}
