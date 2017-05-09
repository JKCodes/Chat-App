//
//  EditView.swift
//  Chat App
//
//  Created by Joseph Kim on 5/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol EditViewDelegate: class {
    func handleEditProfileImage()
    func handleSaveUserInfo(data: [String: AnyObject])
}

class EditView: UIView {
    
    internal var profileImageChanged: Bool = false
    
    internal static let topSpacing: CGFloat = 80
    fileprivate let profileImageLength: CGFloat =  120
    internal static let contentOffset: CGFloat = 50
    fileprivate let contentSpacing: CGFloat = 10
    fileprivate let stackViewHeight: CGFloat = 40 * 5 + 10 * 4
    fileprivate let editSignUpButtonHeight: CGFloat = 40

    internal static var editProfileTopConstraint: NSLayoutConstraint?
    
    fileprivate static let redColor: UIColor = .rgb(r: 255, g: 51, b: 51)
    
    weak var delegate: EditViewDelegate?
    
    var user: User? {
        didSet {
            if !profileImageChanged {
                guard let url = user?.profileImageUrl else { return }
                profileImageView.loadImage(urlString: url)
            }
            firstnameField.text = user?.firstName
            lastnameField.text = user?.lastName
            usernameField.text = user?.username
            emailField.text = user?.email
        }
    }

    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var editProfileImgButton: UIButton = { [unowned self] in
        let button = EditView.returnTemplateButton()
        button.setTitle("  Edit Profile Image  ", for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileImage), for: .touchUpInside)
        return button
    }()
    
    lazy var saveUserInfoButton: UIButton = { [unowned self] in
        let button = EditView.returnTemplateButton()
        button.setTitle("Save User Info", for: .normal)
        button.addTarget(self, action: #selector(handleSaveUserInfo), for: .touchUpInside)
        return button
    }()
    
    let firstnameField: UITextField = {
        let tf = EditView.returnTemplateTextField(placeholder: "First Name")
        return tf
    }()
    
    let lastnameField: UITextField = {
        let tf = EditView.returnTemplateTextField(placeholder: "Last Name")
        return tf
    }()
    
    let usernameField: UITextField = {
        let tf = EditView.returnTemplateTextField(placeholder: "Username")
        return tf
    }()
    
    let emailField: UITextField = {
        let tf = EditView.returnTemplateTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordField: UITextField = {
        let tf = EditView.returnTemplateTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProfileImageArea()
        setupInputArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: - Setup
extension EditView {
    fileprivate func setupProfileImageArea() {
        profileImageView.layer.cornerRadius = profileImageLength / 2
        
        addSubview(profileImageView)
        addSubview(editProfileImgButton)

        EditView.editProfileTopConstraint = profileImageView.anchorAndReturn(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: EditView.topSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)[0]
        profileImageView.anchorCenterXToSuperview()

        editProfileImgButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: editSignUpButtonHeight)
        editProfileImgButton.anchorCenterXToSuperview()
    }
    
    
    fileprivate func setupInputArea() {
        let stackView = UIStackView(arrangedSubviews: [firstnameField, lastnameField, usernameField, emailField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = contentSpacing
        
        addSubview(stackView)
        addSubview(saveUserInfoButton)
        
        stackView.anchor(top: editProfileImgButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: EditView.contentOffset, bottomConstant: 0, rightConstant: EditView.contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
        saveUserInfoButton.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: EditView.contentOffset, bottomConstant: 0, rightConstant: EditView.contentOffset, widthConstant: 0, heightConstant: editSignUpButtonHeight)
    }
}

// MARK: - Handlers
extension EditView {
    func handleEditProfileImage() {
        delegate?.handleEditProfileImage()
    }
    
    func handleSaveUserInfo() {
        guard let firstName = firstnameField.text,
            let lastName = lastnameField.text,
            let username = usernameField.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordField.text,
            let email = emailField.text?.trimmingCharacters(in: .whitespaces),
            let profileImageUrl = profileImageView.lastURLUsedToLoadImage
            else { return }
        
        var data = [String: AnyObject]()
        if firstName != user?.firstName { data["firstName"] = firstName as AnyObject }
        if lastName != user?.lastName { data["lastName"] = lastName as AnyObject }
        if username != user?.username { data["username"] = username as AnyObject }
        if email != user?.email { data["email"] = email as AnyObject }
        if !password.isEmpty { data["password"] = password as AnyObject }
        if profileImageChanged { data["profileImageUrl"] = profileImageUrl as AnyObject}

        delegate?.handleSaveUserInfo(data: data)
    }
}

// MARK: - Others
extension EditView {
    fileprivate static func returnTemplateButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.backgroundColor = EditView.redColor
        button.titleLabel?.font = UIFont.avenirNextFont(size: 14, bold: true)
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    fileprivate static func returnTemplateTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0, alpha: 0.05)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        return textField
    }
}
