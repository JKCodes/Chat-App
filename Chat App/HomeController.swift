//
//  HomeController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, Alerter {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menubutton"), style: .plain, target: self, action: #selector(handleMenu))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfLoggedIn()
    }
    
    
}

extension HomeController {
    func checkIfLoggedIn() {
        if AuthenticationService.shared.currentId() == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            print("user is logged in")
        }
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
    }
}
