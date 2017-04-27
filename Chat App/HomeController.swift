//
//  HomeController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, Alerter, MenuDelegate, EmptyCellDelegate, NewMessagesDelegate {
    
    fileprivate let userCellId = "userCellId"
    fileprivate let emptyCellId = "emptyCellId"
    fileprivate let cellHeight: CGFloat = 75
    
    fileprivate var currentUserId: String?
    fileprivate var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    
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
        
        tableView.backgroundView = backgroundImageView
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        tableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfLoggedIn()

        guard let id = AuthenticationService.shared.currentId() else { return }
        if currentUserId != id {
            setCurrentUser()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let uid = AuthenticationService.shared.currentId(), let toId = message.chatPartnerId() else { return }
        
        DatabaseService.shared.remove(type: .userMessages, firstChild: uid, secondChild: toId) { [weak self] (error, _) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "Deletion request failed", message: error), animated: true, completion: nil)
                return
            }
            
            this.messagesDictionary.removeValue(forKey: toId)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellId, for: indexPath) as! EmptyCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
            cell.selectionStyle = .default
            
            let message = messages[indexPath.row]
            cell.message = message
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: chatPartnerId, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: chatPartnerId, dictionary: dictionary)
            self?.showChatController(user: user)
        }
    }
    
}

// MARK: - Setup
extension HomeController {
    fileprivate func setCurrentUser() {
        guard let currentUserId = AuthenticationService.shared.currentId() else { return }
        
        fetchUser(id: currentUserId, completion: { [weak self] (user) in
            self?.currentUserId = currentUserId
            self?.menuController.user = user
        })
    }

}

// MARK: - Handlers
extension HomeController {
    
    func handleReloadTable() {
        messages = Array(messagesDictionary.values)
        messages.sort { (message1, message2) -> Bool in
            guard let m1 = message1.timestamp, let m2 = message2.timestamp, let time1 = Double(m1), let time2 = Double(m2) else { return true }
            
            return Int(time1) > Int(time2)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func handleSearch() {
        let searchController = SearchController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(searchController, animated: true)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        navigationController?.pushViewController(newMessageController, animated: true)
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

// MARK: - Others
extension HomeController {
    
    func observeUserMessages() {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieve(type: .userMessages, eventType: .childAdded, firstChild: uid, secondChild: nil, propagate: true, sortBy: nil) { [weak self] (snapshot) in
            
            let messageId = snapshot.key
            
            self?.fetchMessage(messageId: messageId)
            self?.attemptReloadOfTable()
            
        }
        
        DatabaseService.shared.retrieve(type: .userMessages, eventType: .childRemoved, firstChild: nil, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            self?.messagesDictionary.removeValue(forKey: snapshot.key)
            self?.attemptReloadOfTable()
        }

    }
    
    fileprivate func checkIfLoggedIn() {
        if AuthenticationService.shared.currentId() == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            messages.removeAll()
            messagesDictionary.removeAll()
            tableView.reloadData()
            
            observeUserMessages()
        }
    }
    
    
    fileprivate func fetchUser(id: String, completion: @escaping (User) -> ()) {
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: id, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
            guard let userDictionary = snapshot.value as? Dictionary<String, Any> else { return }
            let user = User(uid: snapshot.key, dictionary: userDictionary)
            
            completion(user)
        }
    }
    
    fileprivate func fetchMessage(messageId: String) {
        DatabaseService.shared.retrieveOnce(type: .message, eventType: .value, firstChild: messageId, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self else { return }
                        
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    this.messagesDictionary[chatPartnerId] = message
                }
                
                self?.attemptReloadOfTable()
            }
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
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
    
    func showChatController(user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
