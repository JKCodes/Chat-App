//
//  HomeController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, Alerter {
    
    fileprivate let userCellId = "userCellId"
    fileprivate let emptyCellId = "emptyCellId"
    fileprivate let cellHeight: CGFloat = 75
    
    fileprivate var currentUserId: String?
    fileprivate var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    var user: User?
    
    fileprivate let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "bg")
        return iv
    }()
    
    fileprivate lazy var menuController: MenuController = { [unowned self] in
        let controller = MenuController()
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshHome), name: LoginController.refreshHomeNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshData), name: EditController.refreshDataNotificationName, object: nil)
        
        checkIfLoggedIn()
        setupNavBar()
        setupTableView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        navigationController?.isNavigationBarHidden = false
        
        guard let id = AuthenticationService.shared.currentId() else { return }
        if currentUserId != id {
            setCurrentUser()
        }
    }
}

// MARK: - TableView related
extension HomeController {
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

// MARK: - Delegate for NewMessageController
extension HomeController: NewMessagesControllerDelegate {
    func showChatController(user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}

// MARK: - Delegate for MenuController
extension HomeController: MenuControllerDelegate {
    func showController(menuItem: MenuItem) {
        if menuItem.name == .logout {
            handleLogout()
        } else {
            switch menuItem.name {
            case .profile:
                guard let user = user else { return }
                let profileController = ProfileController()
                profileController.user = user
                navigationController?.pushViewController(profileController, animated: true)
            case .help:
                guard let user = user else { return }
                let helpController = HelpController()
                helpController.user = user
                navigationController?.pushViewController(helpController, animated: true)
            case .notification:
                navigationController?.pushViewController(NotificationController(), animated: true)
            case .settings:
                let settingsController = SettingsController(collectionViewLayout: UICollectionViewFlowLayout())
                settingsController.user = user
                navigationController?.pushViewController(settingsController, animated: true)
            default: break
            }
        }
    }
}

// MARK: - Delegate for EmptyCell
extension HomeController: EmptyCellDelegate {
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        navigationController?.pushViewController(newMessageController, animated: true)
    }
}

// MARK: - Setup
extension HomeController {
    
    fileprivate func setupTableView() {
        tableView.backgroundView = backgroundImageView
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        tableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "MSG"
        
        let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "searchbutton"), style: .plain, target: self, action: #selector(handleSearch))
        let newMessageBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "newmessage"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menubutton"), style: .plain, target: self, action: #selector(handleMenu))
        navigationItem.rightBarButtonItems = [newMessageBarButton, searchBarButton]
    }
    
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
    
    func handleRefreshHome() {
        checkIfLoggedIn()
    }
    
    func handleRefreshData() {
        setCurrentUser()
    }
}

// MARK: - Others
extension HomeController {
    
    fileprivate func observeUserMessages() {
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
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: id, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let userDictionary = snapshot.value as? Dictionary<String, Any> else { return }
            let user = User(uid: snapshot.key, dictionary: userDictionary)
            self?.user = user
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
}
