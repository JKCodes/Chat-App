//
//  EditController.swift
//  Chat App
//
//  Created by Joseph Kim on 5/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class EditController: UIViewController, Alerter {
    
    fileprivate var cancelled = false
    fileprivate var profileImageChanged = false
    fileprivate var internalCounter = 0
    
    var editView = EditView()
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(editView)
        editView.fillSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCancelLogin), name: LoginController.cancelLoginNotificationName, object: nil)
    
        setupDelegates()
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

// MARK: - Setup
extension EditController {
    fileprivate func setupDelegates() {
        editView.delegate = self
        editView.firstnameField.delegate = self
        editView.lastnameField.delegate = self
        editView.usernameField.delegate = self
        editView.emailField.delegate = self
        editView.passwordField.delegate = self
    }
}


// MARK: - TextField Delegate
extension EditController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editView.handleSaveUserInfo()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateConstraintTo(value: EditView.contentOffset * -3)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateConstraintTo(value: EditView.topSpacing)
    }
}

// MARK: - EditView Delegate
extension EditController: EditViewDelegate {
    func handleSaveUserInfo(data: [String: AnyObject]) {
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let username = data["username"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let password = data["password"] as? String ?? ""
        
        internalCounter = 0
        
        checkforValidData(firstName: firstName, lastName: lastName, username: username, email: email, password: password) { [weak self] (flag) in
            if flag {
                self?.handleChangeUserVital(email: email, password: password)
                self?.handleUsername(username: username)
                self?.handleDatabaseChange(firstName: firstName, lastName: lastName, username: username, email: email)
            }
        }
        

    }
    
    func handleEditProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - ImagePicker
extension EditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            editView.profileImageView.image = editedImage

        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            editView.profileImageView.image = originalImage
        }
        profileImageChanged = true
        editView.profileImageChanged = true
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Handlers
extension EditController {
    func handleCancelLogin() {
        cancelled = true
        navigationController?.popViewController(animated: true)
    }
    
    func handleAllSaved() {
        if internalCounter == 5 {
            print("all Saved!")
        } else {
            return
        }
    }
    
    func handleChangeUserVital(email: String, password: String) {
        if !email.isEmpty {
            AuthenticationService.shared.updateEmail(email: email, onComplete: { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Error saving email", message: error), animated: true, completion: nil)
                    return
                }
                this.internalCounter += 1
                this.handleAllSaved()
            })
        } else {
            internalCounter += 1
        }
        
        if !password.isEmpty {
            AuthenticationService.shared.updatePassword(password: password, onComplete: { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Error saving password", message: error), animated: true, completion: nil)
                    return
                }
                this.internalCounter += 1
                this.handleAllSaved()
            })
        } else {
            internalCounter += 1
        }
    }
    
    func handleUsername(username: String) {
        if username.isEmpty {
            internalCounter += 2
            return
        }
        
        guard let currentUsername = user?.username else { return }
        
    
        DatabaseService.shared.remove(type: .username, firstChild: currentUsername, secondChild: nil) { [weak self] (error, _) in
            guard let this = self else { return }

            if let error = error {
                this.present(this.alertVC(title: "Error saving username", message: error), animated: true, completion: nil)
                return
            }
            this.internalCounter += 1
            this.handleAllSaved()

        }
        
        let data = [username: 1] as Dictionary<String, AnyObject>
        
        DatabaseService.shared.saveData(type: .username, data: data, firstChild: nil, secondChild: nil, appendAutoId: false, onComplete: { [weak self] (error, _) in
            guard let this = self else { return }

            if let error = error {
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                return
            }
            this.internalCounter += 1
            this.handleAllSaved()
        })
        
    }
    
    func handleDatabaseChange(firstName: String, lastName: String, username: String, email: String) {
        if firstName.isEmpty && lastName.isEmpty && username.isEmpty && email.isEmpty {
            internalCounter += 1
            return
        }
        
        guard let uid = AuthenticationService.shared.currentId() else {
            internalCounter += 1
            return
        }
        
        var data: [String: AnyObject] = [:]
        data["firstName"] = (firstName.isEmpty ? user?.firstName : firstName) as AnyObject
        data["lastName"] = (lastName.isEmpty ? user?.lastName : lastName) as AnyObject
        data["username"] = (username.isEmpty ? user?.username : username) as AnyObject
        data["email"] = (email.isEmpty ? user?.email : email) as AnyObject
        
        DatabaseService.shared.saveData(type: .user, data: data, firstChild: uid, secondChild: nil, appendAutoId: false, onComplete: { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                return
            }
            
            this.internalCounter += 1
            this.handleAllSaved()
        })
    }
}

// MARK: - Others
extension EditController {
    
    fileprivate func checkforValidData(firstName: String, lastName: String, username: String, email: String, password: String, onComplete: @escaping (Bool)->Void) {
        if !password.isEmpty && password.characters.count < 6 {
            present(alertVC(title: "Password error", message: "Password must be 6 characters or longer"), animated: true, completion: nil)
            onComplete(false)
            return
        }
        
        if username.isEmpty {
            onComplete(true)
            return
        }
        
        DatabaseService.shared.isUsernameUnique(username: username) { [weak self] (flag) in
            guard let this = self else { return }
            
            if !flag {
                this.present(this.alertVC(title: "Username Error", message: "\(username) is already taken. Please choose a different username"), animated: true, completion: nil)
                onComplete(false)
                return
            }
            onComplete(true)
        }
    }
    
    fileprivate func animateConstraintTo(value: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            EditView.editProfileTopConstraint?.constant = value
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
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
