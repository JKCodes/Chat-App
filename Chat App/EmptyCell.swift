//
//  EmptyCell.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    
    fileprivate let backgroundCharacterTopOffset: CGFloat = 120
    fileprivate let contentSpacing: CGFloat = 20
    fileprivate let sendButtonWidth: CGFloat = 170
    fileprivate let sendButtonHeight: CGFloat = 36
    fileprivate static let sendButtonRadius: CGFloat = 18
    
    let backgroundCharacterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "background_character")
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "Nothing here yet! \n", attributes: [NSFontAttributeName: UIFont.avenirNextFont(size: 22, bold: true), NSForegroundColorAttributeName: UIColor.darkGray])
        attributedText.append(NSAttributedString(string: "Here is what to do now.", attributes: [NSFontAttributeName: UIFont.avenirNextFont(size: 14, bold: false), NSForegroundColorAttributeName: UIColor.lightGray]))
        
        label.attributedText = attributedText
        return label
    }()
    
    lazy var sendMessageButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = button.tintColor.cgColor
        button.layer.cornerRadius = sendButtonRadius
        button.setImage(#imageLiteral(resourceName: "letter"), for: .normal)
        button.titleLabel?.font = UIFont.avenirNextFont(size: 14, bold: true)
        button.setTitle("  Send a message", for: .normal)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyCell {
    
    fileprivate func setupViews() {
        addSubview(backgroundCharacterImageView)
        addSubview(notificationLabel)
        addSubview(sendMessageButton)
        
        backgroundCharacterImageView.anchorCenterXToSuperview()
        backgroundCharacterImageView.anchorCenterYToSuperview(constant: -backgroundCharacterTopOffset)
        
        notificationLabel.anchorCenterXToSuperview()
        notificationLabel.topAnchor.constraint(equalTo: backgroundCharacterImageView.bottomAnchor, constant: contentSpacing * 2).isActive = true
        
        sendMessageButton.anchorCenterXToSuperview()
        sendMessageButton.anchor(top: notificationLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentSpacing, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: sendButtonWidth, heightConstant: sendButtonHeight)
    }
    
    func handleSendMessage() {
        print("Send message tapped")
    }
}
