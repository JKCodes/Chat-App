//
//  LoginController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, Alerter {

    fileprivate let loginView = LoginView()
    
    var disableSignUp: Bool? {
        didSet {
            guard let disabled = disableSignUp else { return }
            if disabled {
                loginView.disableSignUp = disabled
            }
        }
    }
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            loginView.user = user
        }
    }
    
    static internal let refreshHomeNotificationName = NSNotification.Name(rawValue: "RefreshHome")
    static internal let cancelLoginNotificationName = NSNotification.Name(rawValue: "CancelLogin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(loginView)
        loginView.fillSuperview()

        view.backgroundColor = .white

        loginView.delegate = self
        loginView.emailField.delegate = self
        loginView.passwordField.delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - TextField Delegate
extension LoginController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let email = loginView.emailField.text, let password = loginView.passwordField.text else { return false }
        handleLogin(email: email, password: password)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - LoginView Delegate
extension LoginController: LoginViewDelegate {
    func handleShowSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    func handleLogin(email: String, password: String) {
        if email.characters.count < 1 || password.characters.count < 1 {
            present(alertVC(title: "The Form is Incomplete", message: "All Fields are Required"), animated: true, completion: nil)
            return
        }
        
        if let disabled = disableSignUp, disabled {
            AuthenticationService.shared.renewEmailCredential(email: email, password: password)
            AuthenticationService.shared.reauthenticate(onComplete: { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Reauthentication Error", message: error), animated: true, completion: nil)
                    return
                }
                
                this.navigationController?.popViewController(animated: true)
            })
        } else {
            // Prevent extreme cases where a signup page is still shown after data is saved to Firebase.  This normally would not happen.
            if AuthenticationService.shared.currentId() != nil {
                present(alertVC(title: "A user is already signed in", message: "Cannot create a user while signed in"), animated: true, completion: nil)
                
                return
            }
            
            AuthenticationService.shared.signIn(email: email, password: password) { [weak self] (error, user) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                    return
                }
                
                NotificationCenter.default.post(name: LoginController.refreshHomeNotificationName, object: nil)
                this.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func handleCancel() {
        NotificationCenter.default.post(name: LoginController.cancelLoginNotificationName, object: nil)
        navigationController?.popViewController(animated: true)
    }
}

