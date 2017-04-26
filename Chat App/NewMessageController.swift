//
//  NewMessageController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController, UISearchBarDelegate, SearchCellDelegate {
    
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 80
    fileprivate let contentSpacing: CGFloat = 8
    fileprivate let searchBarLeftSpacing: CGFloat = 100

    fileprivate let window = UIApplication.shared.keyWindow
    fileprivate let currentUserId = AuthenticationService.shared.currentId()
    
    let searchBar = SearchBar()
    
    fileprivate var filteredUsers = [User]()
    fileprivate var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.delegate = self
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: searchBarLeftSpacing, bottomConstant: 0, rightConstant: contentSpacing, widthConstant: 0, heightConstant: 0)
    
        fetchUsers()
        
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        cell.delegate = self
        cell.user = filteredUsers[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        
        userSelected(user: user)
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

        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
}

extension NewMessageController {
    func fetchUsers() {
        DatabaseService.shared.fetchUsers { [weak self] (fetchedUsers) in
            self?.users = fetchedUsers
            self?.filteredUsers = fetchedUsers
            
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        }
    }
    
    func userSelected(user: User) {
        print("selected")
    }
}
