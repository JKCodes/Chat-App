//
//  LoginView.swift
//  Chat App
//
//  Created by Joseph Kim on 5/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func handleLogin(email: String, password: String)
    func handleShowSignUp()
    func handleCancel()
}

class LoginView: UIView {
    fileprivate let appTitleContainerHeight: CGFloat = 150
    fileprivate let contentOffset: CGFloat = 50
    fileprivate let stackViewHeight: CGFloat = 112
    fileprivate let contentSpacing: CGFloat = 12
    fileprivate let loginButtonHeight: CGFloat = 50
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
    var disableSignUp: Bool? {
        didSet {
            dontHaveAccountButton.isHidden = true
            cancelButton.isHidden = false
        }
    }
    
    var user: User? {
        didSet {
        
            guard let email = user?.email else { return }
            emailField.text = email
            emailField.backgroundColor = .lightGray
            emailField.textColor = .darkGray
            emailField.isUserInteractionEnabled = false
        }
    }
    
    weak var delegate: LoginViewDelegate?
    
    let appTitleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = redColor
        return view
    }()
    
    let appTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Snell Roundhand", size: 48)
        label.text = "Chat App"
        label.textColor = .white
        return label
    }()
    
    let emailField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.05)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let passwordField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0.05)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var loginButton: UIButton = { [unowned self] in
        let button = LoginView.returnTemplateButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = LoginView.redColor
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = { [unowned self] in
        let button = LoginView.returnTemplateButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .darkGray
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var dontHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type:  .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 17, g: 154, b: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(this, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupAppTitle()
        setupInputArea()
        setupSignUpButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension LoginView {
    fileprivate func setupAppTitle() {
        addSubview(appTitleContainerView)
        appTitleContainerView.addSubview(appTitleLabel)
        
        appTitleContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: appTitleContainerHeight)
        appTitleLabel.anchorCenterXYSuperview()
    }
    
    fileprivate func setupInputArea() {
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = contentSpacing
        
        addSubview(stackView)
        addSubview(loginButton)
        addSubview(cancelButton)
        
        stackView.anchor(top: appTitleContainerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentOffset, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
        
        loginButton.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: loginButtonHeight)
        cancelButton.anchor(top: loginButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: loginButtonHeight)
    }
    
    fileprivate func setupSignUpButton() {
        addSubview(dontHaveAccountButton)
        
        dontHaveAccountButton.anchor(top: loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        dontHaveAccountButton.anchorCenterXToSuperview()
    }

}

// MARK: - Handlers
extension LoginView {
    @objc func handleLogin() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        delegate?.handleLogin(email: email, password: password)
    }
    
    @objc func handleShowSignUp() {
        delegate?.handleShowSignUp()
    }
    
    @objc func handleCancel() {
        delegate?.handleCancel()
    }
}

// MARK: - Others
extension LoginView {
    fileprivate static func returnTemplateButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.avenirNextFont(size: 14, bold: true)
        button.setTitleColor(.white, for: .normal)
        return button
    }
}
