//
//  UserCell.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
class UserCell: UITableViewCell {
    
    fileprivate let profileImageLength: CGFloat = 50
    fileprivate static let profileImageRadius: CGFloat = 25
    fileprivate let contentOffset: CGFloat = 8
    fileprivate let textFieldLeftConstant: CGFloat = 82
    fileprivate let messageButtonLength: CGFloat = 30
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl, let firstName = user?.firstName, let lastName = user?.lastName, let username = user?.username else { return }
            
            textLabel?.text = "\(firstName) \(lastName)"
            detailTextLabel?.text = "@\(username)"
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = UserCell.profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "selectcontact_btn"), for: .normal)
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        addSubview(messageButton)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset * 2, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
        profileImageView.anchorCenterYToSuperview()
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: contentOffset * 2.5, widthConstant: messageButtonLength, heightConstant: messageButtonLength)
        messageButton.anchorCenterYToSuperview()
        
        setupCell()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else { return }
        
        textLabel.frame = CGRect(x: textFieldLeftConstant, y: textLabel.frame.origin.y - 2, width: textLabel.frame.width, height: textLabel.frame.height)
        
        detailTextLabel.frame = CGRect(x: textFieldLeftConstant, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
}

extension UserCell {
    
    fileprivate func setupCell() {
        textLabel?.font = UIFont.avenirNextFont(size: 20, bold: true)
        detailTextLabel?.font = UIFont.avenirNextFont(size: 14, bold: false)
        detailTextLabel?.textColor = UIColor(white: 0, alpha: 0.5)
        
    }
}
