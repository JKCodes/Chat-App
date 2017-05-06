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
    fileprivate var profileImage: UIImage?
    fileprivate var internalCounter = 0
    
    var editView = EditView()
    
    var user: User?
    
    let grayScreen: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()
    
    static internal let refreshDataNotificationName = NSNotification.Name(rawValue: "RefreshData")
    
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
        
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(grayScreen)
        grayScreen.fillSuperview()
        
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let username = data["username"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let password = data["password"] as? String ?? ""
        let profileImageUrl = data["profileImageUrl"] as? String ?? ""
        
        if firstName.isEmpty && lastName.isEmpty && username.isEmpty && email.isEmpty && password.isEmpty && profileImageUrl.isEmpty {
            internalCounter = -1
            handleAllSaved()
        }
        
        internalCounter = 0
        
        checkforValidData(username: username, email: email, password: password) { [weak self] (flag) in
            if flag {
                self?.handleChangeUserVital(email: email, password: password)
                self?.handleUsername(username: username)
                self?.handleEmail(email: email)
                self?.handleProfileImage(profileImageUrl: profileImageUrl)
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
        profileImage = editView.profileImageView.image
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
        if internalCounter == -1 {
            grayScreen.removeFromSuperview()
            present(alertVC(title: "No new information entered", message: "Your profile was not updated."), animated: true, completion: nil)
        } else if internalCounter == 9 {
            NotificationCenter.default.post(name: EditController.refreshDataNotificationName, object: nil)
            grayScreen.removeFromSuperview()
            navigationController?.popViewController(animated: true)
        } else if internalCounter == -2 {
            grayScreen.removeFromSuperview()
            present(alertVC(title: "Error saving data", message: "Your profile was only partially updated. Please contact the developer if your data has been corrupted"), animated: true, completion: nil)
        } else {
            return
        }
    }
    
    fileprivate func handleResults(error: String?) {
        if error != nil {
            internalCounter = -2
        } else {
            internalCounter += 1
        }
        handleAllSaved()
    }
    
    fileprivate func handleChangeUserVital(email: String, password: String) {
        if !email.isEmpty {
            AuthenticationService.shared.updateEmail(email: email, onComplete: { [weak self] (error, _) in
                self?.handleResults(error: error)
            })
        } else {
            internalCounter += 1
        }
        
        if !password.isEmpty {
            AuthenticationService.shared.updatePassword(password: password, onComplete: { [weak self] (error, _) in
                self?.handleResults(error: error)
            })
        } else {
            internalCounter += 1
        }
    }
    
    fileprivate func handleReplaceUniqueItems(type: DataTypes, old: String, new: String) {
        
        DatabaseService.shared.remove(type: type, firstChild: old, secondChild: nil) { [weak self] (error, _) in
            self?.handleResults(error: error)
        }
        
        let data = [new: 1] as Dictionary<String, AnyObject>
        
        DatabaseService.shared.saveData(type: type, data: data, firstChild: nil, secondChild: nil, appendAutoId: false, onComplete: { [weak self] (error, _) in
            self?.handleResults(error: error)
        })

    }
    
    func handleEmail(email: String) {
        if email.isEmpty {
            internalCounter += 2
            return
        }
        
        guard let currentEmail = user?.email.replacingOccurrences(of: ".", with: "%2E") else { return }
        
        handleReplaceUniqueItems(type: .email, old: currentEmail, new: email.replacingOccurrences(of: ".", with: "%2E"))
    }
    
    func handleUsername(username: String) {
        if username.isEmpty {
            internalCounter += 2
            return
        }
        
        guard let currentUsername = user?.username else { return }
        
        handleReplaceUniqueItems(type: .username, old: currentUsername, new: username)
    }
    
    func handleProfileImage(profileImageUrl: String) {
        if profileImageUrl.isEmpty {
            internalCounter += 2
            return
        }
        
        guard let image = editView.profileImageView.image, let uploadData = UIImageJPEGRepresentation(image, 0.3), let uid = AuthenticationService.shared.currentId() else {
            internalCounter += 2
            return
        }
        
        StorageService.shared.uploadToStorage(type: .profile, data: uploadData, url: nil, filename: uid) { [weak self] (error, metadata) in
            self?.handleResults(error: error)
            
            guard let imgUrl = metadata?.downloadURL()?.absoluteString else { return }
            let data = ["profileImageUrl": imgUrl] as Dictionary<String, AnyObject>
            
            if self?.internalCounter == -2 { return }
            
            DatabaseService.shared.saveData(type: .user, data: data, firstChild: uid, secondChild: nil, appendAutoId: false, onComplete: { (error, _) in
                self?.handleResults(error: error)
            })
        }
        
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
            self?.handleResults(error: error)
        })
    }
}

// MARK: - Others
extension EditController {
    
    fileprivate func checkforValidData(username: String, email: String, password: String, onComplete: @escaping (Bool)->Void) {
        
        // Check if password is present & longer than 5 characters
        if !password.isEmpty && password.characters.count < 6 {
            present(alertVC(title: "Password error", message: "Password must be 6 characters or longer"), animated: true, completion: nil)
            onComplete(false)
            return
        }
        
        if !username.isEmpty && !email.isEmpty {
            checkForValidData(type: .username, query: username, onComplete: { [weak self] (flag) in
                if flag {
                    self?.checkForValidData(type: .email, query: email.replacingOccurrences(of: ".", with: "%2E"), onComplete: onComplete)
                } else {
                    return
                }
            })
        } else if !username.isEmpty {
            checkForValidData(type: .username, query: username, onComplete: onComplete)
        } else if !email.isEmpty {
            checkForValidData(type: .email, query: email.replacingOccurrences(of: ".", with: "%2E"), onComplete: onComplete)
        } else {
            onComplete(true)
        }
    }
    
    fileprivate func checkForValidData(type: DataTypes, query: String, onComplete: @escaping (Bool) -> Void) {
        DatabaseService.shared.isUnique(type: type, eventType: .value, query: query) { [weak self] (flag) in
            guard let this = self else { return }
            
            if !flag {
                this.present(this.alertVC(title: "\(type.rawValue.capitalized) error" , message: "Provided \(type.rawValue) is already taken. Please choose a different \(type.rawValue)"), animated: true, completion: nil)
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
