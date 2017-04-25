//
//  HomeController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, Alerter, MenuDelegate {
    
    fileprivate let messageCellId = "messageCellId"
    fileprivate let emptyCellId = "emptyCellId"
    fileprivate let cellHeight: CGFloat = 75
    
    fileprivate var currentUserId: String?
    fileprivate var messages = [String]()
    
    fileprivate let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "bg")
        return iv
    }()
    
    fileprivate lazy var menuController: MenuController = { [weak self] in
        guard let this = self else { return MenuController() }
        
        let controller = MenuController()
        controller.delegate = this
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "MSG"
        
        let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "searchbutton"), style: .plain, target: self, action: #selector(handleSearch))
        let newMessageBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "newmessage"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menubutton"), style: .plain, target: self, action: #selector(handleMenu))
        navigationItem.rightBarButtonItems = [newMessageBarButton, searchBarButton]

        checkIfLoggedIn()
                
        tableView.backgroundView = backgroundImageView
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: messageCellId)
        tableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let id = AuthenticationService.shared.currentId() else { return }
        if currentUserId != id {
            setCurrentUser()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            tableView.isScrollEnabled = false
            return 1
        } else {
            tableView.isScrollEnabled = true
            return messages.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellId, for: indexPath)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: messageCellId, for: indexPath)
            cell.selectionStyle = .default
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if messages.count == 0 {
            let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
            return tableView.frame.height - navbarHeight
        } else {
            return cellHeight
        }
    }
    
}

extension HomeController {
    
    fileprivate func checkIfLoggedIn() {
        if AuthenticationService.shared.currentId() == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            print("user is logged in")
        }
    }
    
    fileprivate func setCurrentUser() {
        guard let currentUserId = AuthenticationService.shared.currentId() else { return }
        
        fetchUser(id: currentUserId, completion: { [weak self] (user) in
            self?.currentUserId = currentUserId
            self?.menuController.user = user
        })
    }
    
    fileprivate func fetchUser(id: String, completion: @escaping (User) -> ()) {
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: id, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
            guard let userDictionary = snapshot.value as? Dictionary<String, Any> else { return }
            let user = User(dictionary: userDictionary)
            
            completion(user)
        }
    }
    
    func showController(menuItem: MenuItem) {
        
        if menuItem.name == .logout {
            handleLogout()
        } else {
            let vc = UIViewController()
            vc.navigationItem.title = menuItem.name.rawValue
            vc.view.backgroundColor = .white
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func handleSearch() {
        let searchController = SearchController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(searchController, animated: true)
    }
    
    func handleNewMessage() {
        print("newMessage button Tapped")
    }
    
    func handleLogout() {
        AuthenticationService.shared.signOut { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "Error logging out", message: error), animated: true, completion: nil)
                return
            }

            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            this.present(navController, animated: true, completion: nil)
        }
    }
    
    func handleMenu() {
        menuController.showMenu()
    }
}
