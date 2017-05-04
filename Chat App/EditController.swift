//
//  EditController.swift
//  Chat App
//
//  Created by Joseph Kim on 5/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class EditController: UIViewController {
    
    fileprivate var cancelled = false
    
    var editView = EditView()
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(editView)
        editView.fillSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCancelLogin), name: LoginController.cancelLoginNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cancelled { return }
        
        attemptReauthenticate { [weak self] (flag) in
            if flag {
                self?.displayLoginController()
                return
            }
            self?.navigationController?.isNavigationBarHidden = false
            self?.navigationItem.title = "Edit Profile"
            self?.editView.user = self?.user
        }
    }
    
}


// MARK: - Handlers
extension EditController {
    func handleCancelLogin() {
        cancelled = true
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Others
extension EditController {
    
    fileprivate func attemptReauthenticate(onComplete: @escaping (Bool) -> Void) {
        AuthenticationService.shared.reauthenticate { (error, _) in
            if error != nil {
                onComplete(true)
                return
            }
            onComplete(false)
        }
    }
    
    fileprivate func displayLoginController() {
        let loginVC = LoginController()
        loginVC.disableSignUp = true
        loginVC.user = user
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
