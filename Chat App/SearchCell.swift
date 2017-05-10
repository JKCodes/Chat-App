//
//  SearchCell.swift
//  Chat App
//
//  Created by Joseph Kim on 4/25/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol SearchCellDelegate: class {
    func addRemoveFriend(user: User)
    func isFriend(user: User, onComplete: @escaping (Bool) -> Void)
}

class SearchCell: BaseCollectionViewCell {
    
    fileprivate let cellSpacing: CGFloat = 8
    fileprivate let profileImageHeight: CGFloat = 50
    fileprivate let addButonLength: CGFloat = 30
    fileprivate let usernameTopOffset: CGFloat = 15
    fileprivate let separatorHeight: CGFloat = 0.5
        
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl, let firstName = user?.firstName, let lastName = user?.lastName, let username = user?.username else { return }
            
            fullnameLabel.text = "\(firstName) \(lastName)"
            usernameLabel.text = "@\(username)"
            
            profileImageView.loadImage(urlString: profileImageUrl)
            
            delegate?.isFriend(user: user!, onComplete: { [weak self] (isFriend) in
                self?.setButtonImage(isFriend: isFriend)
            })
        }
    }
    
    weak var delegate: SearchCellDelegate?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Fullname"
        label.font = UIFont.avenirNextFont(size: 20, bold: true)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.avenirNextFont(size: 14, bold: false)
        label.textColor = UIColor(white: 0, alpha: 0.5)
        return label
    }()
    
    lazy var addButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "addfriend_btn"), for: .normal)
        button.addTarget(this, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)
        addSubview(fullnameLabel)
        addSubview(addButton)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: cellSpacing * 2, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageHeight, heightConstant: profileImageHeight)
        profileImageView.anchorCenterYToSuperview()
        profileImageView.layer.cornerRadius = profileImageHeight / 2
        fullnameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: usernameTopOffset, leftConstant: cellSpacing * 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: fullnameLabel.leftAnchor, bottom: nil, right: nil, topConstant: cellSpacing / 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        addButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: cellSpacing * 2.5, widthConstant: addButonLength, heightConstant: addButonLength)
        addButton.anchorCenterYToSuperview()
        separatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: separatorHeight)
    }
}

// MARK: - Handlers and Others
extension SearchCell {
    func handleAdd() {
        guard let user = user else { return }
        
        delegate?.addRemoveFriend(user: user)  
    }
    
    fileprivate func setButtonImage(isFriend: Bool) {
        if isFriend {
            addButton.setImage(#imageLiteral(resourceName: "clear_btn"), for: .normal)
        } else {
            addButton.setImage(#imageLiteral(resourceName: "addfriend_btn"), for: .normal)
        }
    }
}
