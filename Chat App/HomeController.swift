//
//  HomeController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, Alerter {
    
    fileprivate let messageCellId = "messageCellId"
    fileprivate let emptyCellId = "emptyCellId"
    fileprivate let cellHeight: CGFloat = 75
    
    fileprivate var messages = [String]()
    
    fileprivate let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "bg")
        return iv
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
        
        tableView.alwaysBounceVertical = false
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
    
    func handleSearch() {
        print("search button tapped")
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
        print("Menu button clicked")
        handleLogout()
    }
}
