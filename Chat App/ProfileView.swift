//
//  ProfileView.swift
//  Chat App
//
//  Created by Joseph Kim on 5/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: class {
    func handleBack()
    func handleEditProfile(user: User)
}

class ProfileView: UIView {
    
    fileprivate let profileImageRatio: CGFloat = 0.6
    fileprivate let buttonLength: CGFloat = 80
    fileprivate let buttonSpacing: CGFloat = 50
    fileprivate let labelSpacing: CGFloat = 12
    
    var user: User? {
        didSet {
            guard let url = user?.profileImageUrl,
                let firstName = user?.firstName,
                let lastName = user?.lastName,
                let username = user?.username else { return }
            profileImageView.loadImage(urlString: url)
            nameLabel.text = "\(firstName) \(lastName)"
            usernameLabel.text = "@\(username)"
        }
    }
    
    weak var delegate: ProfileViewDelegate?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.07)
        return view
    }()
    
    lazy var editProfileButton: UIButton = { [unowned self] in
        let button = ProfileView.setupBasicButton()
        button.backgroundColor = UIColor.rgb(r: 242, g: 78, b: 100)
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = { [unowned self] in
        let button = ProfileView.setupBasicButton()
        button.backgroundColor = UIColor.rgb(r: 63, g: 204, b: 245)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 48, bold: true)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 29, bold: false)
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: - Setup
extension ProfileView {
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        addSubview(divider)
        addSubview(editProfileButton)
        addSubview(backButton)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        
        editProfileButton.layer.cornerRadius = buttonLength / 2
        backButton.layer.cornerRadius = buttonLength / 2
        
        setupConstraints()
        
    }
    
    fileprivate func setupConstraints() {
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        profileImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: profileImageRatio).isActive = true
        divider.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        editProfileButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: -buttonLength / 2, leftConstant: 0, bottomConstant: 0, rightConstant: buttonSpacing, widthConstant: buttonLength, heightConstant: buttonLength)
        backButton.anchor(top: editProfileButton.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: buttonSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: buttonLength, heightConstant: buttonLength)
        nameLabel.anchor(top: backButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: labelSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.anchorCenterXToSuperview()
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: labelSpacing / 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameLabel.anchorCenterXToSuperview()
    }
    
    fileprivate static func setupBasicButton() -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.avenirNextFont(size: 22, bold: true)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        return button
    }
    
}

// MARK: - Handlers
extension ProfileView {
    @objc func handleEditProfile() {
        guard let user = user else { return }
        delegate?.handleEditProfile(user: user)
    }
    
    @objc func handleBack() {
        delegate?.handleBack()
    }
}
