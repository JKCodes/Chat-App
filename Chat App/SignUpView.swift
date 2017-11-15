//
//  SignUpView.swift
//  Chat App
//
//  Created by Joseph Kim on 5/10/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol SignUpViewDelegate: class {
    func didEditProfileImage()
    func didSignUp(data: [String: AnyObject])
    func didShowLogin()
}

class SignUpView: UIView {
    internal var addProfileTopConstraint: NSLayoutConstraint?
    
    fileprivate let addProfileImageLength: CGFloat = 150
    fileprivate let stackViewHeight: CGFloat = 40 * 5 + 10 * 4
    fileprivate let signUpButtonHeight: CGFloat = 40
    internal static let contentOffset: CGFloat = 50
    fileprivate let contentSpacing: CGFloat = 10
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
    weak var delegate: SignUpViewDelegate?
    
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
        let tf = SignUpView.baseTextField(placeholder: "First Name")
        return tf
    }()
    
    let lastnameField: UITextField = {
        let tf = SignUpView.baseTextField(placeholder: "Last Name")
        return tf
    }()
    
    let usernameField: UITextField = {
        let tf = SignUpView.baseTextField(placeholder: "Username")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let emailField: UITextField = {
        let tf = SignUpView.baseTextField(placeholder: "Email")
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordField: UITextField = {
        let tf = SignUpView.baseTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var signUpButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = SignUpView.redColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(this, action: #selector(handleSignUp), for: .touchUpInside)
        return button
        }()
    
    lazy var alreadyHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 17, g: 154, b: 237)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(this, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAddImage()
        setupInputArea()
        setupAlreadyHaveAccountButton()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension SignUpView {
    fileprivate func setupAddImage() {
        addSubview(addProfileImageButton)
        addSubview(profileImageHelperLabel)
        
        addProfileTopConstraint = addProfileImageButton.anchorAndReturn(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: SignUpView.contentOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: addProfileImageLength, heightConstant: addProfileImageLength)[0]
        addProfileImageButton.anchorCenterXToSuperview()
        profileImageHelperLabel.anchor(top: addProfileImageButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        profileImageHelperLabel.anchorCenterXToSuperview()
    }
    
    fileprivate func setupInputArea() {
        let stackView = UIStackView(arrangedSubviews: [firstnameField, lastnameField, usernameField, emailField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = contentSpacing
        
        addSubview(stackView)
        addSubview(signUpButton)
        
        stackView.anchor(top: profileImageHelperLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: SignUpView.contentOffset, bottomConstant: 0, rightConstant: SignUpView.contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
        signUpButton.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: SignUpView.contentOffset, bottomConstant: 0, rightConstant: SignUpView.contentOffset, widthConstant: 0, heightConstant: signUpButtonHeight)
    }
    
    fileprivate func setupAlreadyHaveAccountButton() {
        addSubview(alreadyHaveAccountButton)
        
        alreadyHaveAccountButton.anchor(top: signUpButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        alreadyHaveAccountButton.anchorCenterXToSuperview()
    }
}

// MARK: - Handlers
extension SignUpView {
    @objc func handleSignUp() {
        guard let firstName = firstnameField.text,
            let lastName = lastnameField.text,
            let username = usernameField.text,
            let email = emailField.text,
            let password = passwordField.text
            else { return }
        
        let data = ["firstName": firstName, "lastName": lastName, "username": username, "email": email, "password": password] as [String: AnyObject]
        
        delegate?.didSignUp(data: data)
    }
    
    @objc func handleAlreadyHaveAccount() {
        delegate?.didShowLogin()
    }
    
    @objc func handleAddProfile() {
        delegate?.didEditProfileImage()
    }
}

// MARK: - Others
extension SignUpView {
    fileprivate static func baseTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0, alpha: 0.05)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        return textField
    }
    
    internal func setBorder() {
        addProfileImageButton.layer.cornerRadius = addProfileImageButton.frame.width / 2
        addProfileImageButton.layer.masksToBounds = true
        addProfileImageButton.layer.borderColor = UIColor.black.cgColor
        addProfileImageButton.layer.borderWidth = 1.5
    }
}
