//
//  LoginController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, Alerter {

    fileprivate let appTitleContainerHeight: CGFloat = 150
    fileprivate let contentOffset: CGFloat = 50
    fileprivate let stackViewHeight: CGFloat = 112
    fileprivate let contentSpacing: CGFloat = 12
    fileprivate let loginButtonHeight: CGFloat = 50
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
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
    
    lazy var loginButton: UIButton = { [weak self] in
         guard let this = self else { return UIButton() }
         let button = UIButton(type: .system)
         button.setTitle("Login", for: .normal)
         button.backgroundColor = redColor
         button.layer.cornerRadius = 5
         button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
         button.setTitleColor(.white, for: .normal)
         button.addTarget(this, action: #selector(handleLogin), for: .touchUpInside)
         return button
     }()
    
    lazy var dontHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type:  .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.rgb(r: 17, g: 154, b: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(this, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
       
        emailField.delegate = self
        passwordField.delegate = self
        
        setupAppTitle()
        setupInputArea()
        setupSignUpButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleLogin()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension LoginController {
    
    fileprivate func setupAppTitle() {
        view.addSubview(appTitleContainerView)
        appTitleContainerView.addSubview(appTitleLabel)
        
        appTitleContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: appTitleContainerHeight)
        appTitleLabel.anchorCenterXYSuperview()
    }
    
    fileprivate func setupInputArea() {
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = contentSpacing
        
        view.addSubview(stackView)
        view.addSubview(loginButton)
        
        stackView.anchor(top: appTitleContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentOffset, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
        
        loginButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentSpacing, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: loginButtonHeight)
    }
    
    fileprivate func setupSignUpButton() {
        view.addSubview(dontHaveAccountButton)
        
        dontHaveAccountButton.anchor(top: loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        dontHaveAccountButton.anchorCenterXToSuperview()
    }

    func handleShowSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    func handleLogin() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        if email.characters.count < 1 || password.characters.count < 1 {
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
        
        AuthenticationService.shared.signIn(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                return
            }
            
            this.dismiss(animated: true, completion: nil)
        }
    }
}

