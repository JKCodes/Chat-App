//
//  MenuHeader.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class MenuHeader: BaseCell {
    
    fileprivate let nameLabelTopOffset: CGFloat = 40
    fileprivate let nameLabelLeftOffset: CGFloat = 20
    fileprivate let usernameLabelTopOffset: CGFloat = 4
    fileprivate let profileImageLeftOffset: CGFloat = 20
    fileprivate let profileImageLength: CGFloat = 80
    fileprivate static let profileImageRadius: CGFloat = 40
    
    var user: User? {
        didSet {
            guard let firstName = user?.firstName, let lastName = user?.lastName, let username = user?.username, let imageUrl = user?.profileImageUrl else { return }
            nameLabel.text = "\(firstName) \(lastName)"
            usernameLabel.text = "@\(username)"
            profileImageView.loadImage(urlString: imageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = profileImageRadius
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 20, bold: true)
        label.textColor = .white
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 14, bold: false)
        label.textColor = .white
        return label
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.rgb(r: 0, g: 65, b: 151)
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: profileImageLeftOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
        profileImageView.anchorCenterYToSuperview()
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: nameLabelTopOffset, leftConstant: nameLabelLeftOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, topConstant: usernameLabelTopOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
