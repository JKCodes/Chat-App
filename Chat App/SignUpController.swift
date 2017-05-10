//
//  SignUpController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, Alerter {
    
    fileprivate let signUpView = SignUpView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupDelegates()
    }
}

// MARK: - Delegate for ImagePicker
extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedimage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            signUpView.addProfileImageButton.setImage(editedimage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            signUpView.addProfileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        signUpView.setBorder()        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Delegate for TextField
extension SignUpController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signUpView.handleSignUp()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateConstraintTo(value: SignUpView.contentOffset * -3)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateConstraintTo(value: SignUpView.contentOffset)
    }
}

// MARK: - Delegate for SignUpView
extension SignUpController: SignUpViewDelegate {
    func didShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func didSignUp(data: [String : AnyObject]) {
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let username = data["username"] as? String ?? ""
        let password = data["password"] as? String ?? ""
        var email = data["email"] as? String ?? ""
        
        if !email.isEmpty { email = email.lowercased() }
        
        if firstName.characters.count < 1 || lastName.characters.count < 1 || username.characters.count < 1 || password.characters.count < 1 || email.characters.count < 1 {
            present(alertVC(title: "The Form is Incomplete", message: "All Fields are Required"), animated: true, completion: nil)
            return
        }
        
        // Prevent extreme cases where a signup page is still shown after data is saved to Firebase.  This normally would not happen.
        if AuthenticationService.shared.currentId() != nil {
            present(alertVC(title: "A user is already signed in", message: "Cannot create a user while signed in"), animated: true, completion: nil)
            return
        }
        
        createUser(firstName: firstName, lastName: lastName, username: username, email: email, password: password)
    }
    
    func didEditProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
}


// MARK: - Setup
extension SignUpController {
    fileprivate func setupViews() {
        view.addSubview(signUpView)
        signUpView.fillSuperview()
    }
    
    fileprivate func setupDelegates() {
        signUpView.delegate = self
        signUpView.firstnameField.delegate = self
        signUpView.lastnameField.delegate = self
        signUpView.usernameField.delegate = self
        signUpView.emailField.delegate = self
        signUpView.passwordField.delegate = self
    }
}

// MARK: - Others {
extension SignUpController {
    
    fileprivate func animateConstraintTo(value: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.signUpView.addProfileTopConstraint?.constant = value
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func createUser(firstName: String, lastName: String, username: String, email: String, password: String) {
        AuthenticationService.shared.createUser(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                return
            }
            
            DatabaseService.shared.isUnique(type: .username, eventType: .value, query: username, onComplete: { (flag) in
                if !flag {
                    this.present(this.alertVC(title: "Duplicate username", message: "The chosen username has already been taken.  Please choose a different username"), animated: true, completion: nil)
                    AuthenticationService.shared.deleteCurrentUser { return }
                    return
                }
                
                guard let uid = user?.uid else { return }
                this.saveDataToFirebase(uid: uid, firstName: firstName, lastName: lastName, username: username, email: email)
            })
        }
    }
    
    fileprivate func saveDataToFirebase(uid: String, firstName: String, lastName: String, username: String, email: String) {
        guard let image = signUpView.addProfileImageButton.imageView?.image, let uploadData = UIImageJPEGRepresentation(image, 0.3), let uid = AuthenticationService.shared.currentId() else { return }
        
        StorageService.shared.uploadToStorage(type: .profile, data: uploadData, url: nil, filename: uid) { [weak self] (error, metadata) in
            guard let this = self else { return }

            if let error = error {
                this.present(this.alertVC(title: "Error saving to storage", message: error), animated: true, completion: nil)
                AuthenticationService.shared.deleteCurrentUser { return }
                return
            }
            
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            var data = ["firstName": firstName, "lastName": lastName, "username": username, "profileImageUrl": profileImageUrl, "email": email, "exactMatch": 0, "hideDefault": 0, "noNotifications": 0] as Dictionary<String, AnyObject>
        
            DatabaseService.shared.saveData(type: .user, data: data, firstChild: uid, secondChild: nil, appendAutoId: false, onComplete: { (error, _) in
                if let error = error {
                    this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                    AuthenticationService.shared.deleteCurrentUser { return }
                    return
                }
                
                data = [username: 1] as Dictionary<String, AnyObject>
                
                DatabaseService.shared.saveData(type: .username, data: data, firstChild: nil, secondChild: nil, appendAutoId: false, onComplete: { (error, _) in
                    if let error = error {
                        this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                        AuthenticationService.shared.deleteCurrentUser { return }
                        return
                    }
                    
                    this.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
}
