//
//  SignUpController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, UITextFieldDelegate {
    
    fileprivate let addProfileImageLength: CGFloat = 150
    fileprivate let stackViewHeight: CGFloat = 40 * 5 + 10 * 4
    fileprivate let signUpButtonHeight: CGFloat = 40
    fileprivate let contentOffset: CGFloat = 50
    fileprivate let contentSpacing: CGFloat = 10
    
    fileprivate var addProfileTopConstraint: NSLayoutConstraint?
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
    lazy var addProfileImageView: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "background_character"), for: .normal)
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
        return tf
    }()
    
    let emailField: UITextField = {
        let tf = SignUpController.baseTextField(placeholder: "Email")
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
    
    fileprivate func setupAddImage() {
        view.addSubview(addProfileImageView)
        view.addSubview(profileImageHelperLabel)
        
        addProfileTopConstraint = addProfileImageView.anchorAndReturn(top: view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: contentOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: addProfileImageLength, heightConstant: addProfileImageLength)[0]
        addProfileImageView.anchorCenterXToSuperview()
        profileImageHelperLabel.anchor(top: addProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
}

extension SignUpController {
    
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
    
    fileprivate func animateConstraintTo(value: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let this = self else { return }
            this.addProfileTopConstraint?.constant = value
            this.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func handleAddProfile() {
        print("change profile image tapped")
    }
    
    func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func handleSignUp() {
        print("Sign Up Pressed")
    }
}
