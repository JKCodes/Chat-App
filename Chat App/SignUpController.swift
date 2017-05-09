//
//  SignUpController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, UITextFieldDelegate, Alerter, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let addProfileImageLength: CGFloat = 150
    fileprivate let stackViewHeight: CGFloat = 40 * 5 + 10 * 4
    fileprivate let signUpButtonHeight: CGFloat = 40
    fileprivate let contentOffset: CGFloat = 50
    fileprivate let contentSpacing: CGFloat = 10
    
    fileprivate var addProfileTopConstraint: NSLayoutConstraint?
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
    lazy var addProfileImageButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "background_character").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(this, action: #selector(handleAddProfile), for: .touchUpInside)
        return button
    }()
    
    let profileImageHelperLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap above to set profile picture"
        label.font = .systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    
    
    let firstnameField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "First Name")
        return tf
    }()
    
    let lastnameField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "Last Name")
        return tf
    }()
    
    let usernameField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "Username")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let emailField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "Email")
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var signUpButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = redColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(this, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    lazy var alreadyHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.rgb(r: 17, g: 154, b: 237)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(this, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
     
        setupDelegates()
        setupAddImage()
        setupInputArea()
        setupAlreadyHaveAccountButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSignUp()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateConstraintTo(value: contentOffset * -3)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateConstraintTo(value: contentOffset)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedimage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            addProfileImageButton.setImage(editedimage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            addProfileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        addProfileImageButton.layer.cornerRadius = addProfileImageButton.frame.width / 2
        addProfileImageButton.layer.masksToBounds = true
        addProfileImageButton.layer.borderColor = UIColor.black.cgColor
        addProfileImageButton.layer.borderWidth = 1.5
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpController {
    
    fileprivate func setupAddImage() {
        view.addSubview(addProfileImageButton)
        view.addSubview(profileImageHelperLabel)
        
        addProfileTopConstraint = addProfileImageButton.anchorAndReturn(top: view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: contentOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: addProfileImageLength, heightConstant: addProfileImageLength)[0]
        addProfileImageButton.anchorCenterXToSuperview()
        profileImageHelperLabel.anchor(top: addProfileImageButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        profileImageHelperLabel.anchorCenterXToSuperview()
    }
    
    fileprivate func setupInputArea() {
        let stackView = UIStackView(arrangedSubviews: [firstnameField, lastnameField, usernameField, emailField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = contentSpacing
        
        view.addSubview(stackView)
        view.addSubview(signUpButton)
        
        stackView.anchor(top: profileImageHelperLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentSpacing, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
        signUpButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentSpacing, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: signUpButtonHeight)
    }
    
    fileprivate func setupAlreadyHaveAccountButton() {
        view.addSubview(alreadyHaveAccountButton)
        
        alreadyHaveAccountButton.anchor(top: signUpButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        alreadyHaveAccountButton.anchorCenterXToSuperview()
    }
    
    fileprivate func animateConstraintTo(value: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let this = self else { return }
            this.addProfileTopConstraint?.constant = value
            this.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate static func baseTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0, alpha: 0.05)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        return textField
    }
    
    fileprivate func setupDelegates() {
        firstnameField.delegate = self
        lastnameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func handleAddProfile() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func handleSignUp() {
        guard let firstName = firstnameField.text, let lastName = lastnameField.text, let username = usernameField.text, let password = passwordField.text, let email = emailField.text?.lowercased() else { return }
        if firstName.characters.count < 1 || lastName.characters.count < 1 || username.characters.count < 1 || password.characters.count < 1 || email.characters.count < 1 {
            present(alertVC(title: "The Form is Incomplete", message: "All Fields are Required"), animated: true, completion: nil)
            return
        }
        
        // Prevent extreme cases where a signup page is still shown after data is saved to Firebase.  This normally would not happen.
        if AuthenticationService.shared.currentId() != nil {
            present(alertVC(title: "A user is already signed in", message: "Cannot create a user while signed in"), animated: true, completion: nil)
            
            // Temporarilly, this will sign you out. This will be removed in future.
            AuthenticationService.shared.signOut(onCompletion: { [weak self] (error, _) in
                guard let this = self else { return }
                if let error = error {
                    this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                    return
                }
            })
            
            return
        }
        
        createUser(firstName: firstName, lastName: lastName, username: username, email: email, password: password)
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
        guard let image = self.addProfileImageButton.imageView?.image, let uploadData = UIImageJPEGRepresentation(image, 0.3), let uid = AuthenticationService.shared.currentId() else { return }
        
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
