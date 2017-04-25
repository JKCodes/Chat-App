//
//  MenuItemCell.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class MenuItemCell: BaseCollectionViewCell {
    
    fileprivate let contentSpacing: CGFloat = 16
    fileprivate let iconImageLength: CGFloat = 30
 
    var menuItem: MenuItem? {
        didSet {
            nameLabel.text = menuItem?.name.rawValue
            
            if let image = menuItem?.image {
                iconImageView.image = image
            }
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "SETTING"
        label.font = UIFont.avenirNextFont(size: 21, bold: true)
        label.textColor = .white
        return label
    }()
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "settings")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        iconImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentSpacing * 1.5, bottomConstant: 0, rightConstant: 0, widthConstant: iconImageLength, heightConstant: iconImageLength)
        iconImageView.anchorCenterYToSuperview()
        nameLabel.anchor(top: topAnchor, left: iconImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: contentSpacing, bottomConstant: 0, rightConstant: contentSpacing, widthConstant: 0, heightConstant: 0)
    }
}
