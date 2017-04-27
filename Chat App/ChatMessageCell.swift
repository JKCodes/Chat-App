//
//  ChatMessageCell.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ChatMessageCell: BaseCollectionViewCell {
    
    fileprivate let bubbleViewWidth: CGFloat = 200
    internal static let textViewFontSize: CGFloat = 16
    internal static let cellWidth: CGFloat = 200
    internal static let cellHeightMinusContents: CGFloat = 20
    fileprivate let contentOffset: CGFloat = 8
    internal static let blueColor: UIColor = .rgb(r: 0, g: 137, b: 249)
    fileprivate let profileImageLength: CGFloat = 32
    fileprivate static let profileImageRadius: CGFloat = 16

    internal var bubbleWidthConstraint: NSLayoutConstraint?
    internal var bubbleRightConstraint: NSLayoutConstraint?
    internal var bubbleLeftConstraint: NSLayoutConstraint?

    var message: Message?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Temp"
        tv.font = UIFont.avenirNextFont(size: textViewFontSize, bold: false)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    
    override func setupViews() {
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleRightConstraint = bubbleView.anchorAndReturn(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: 0)[1]
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleLeftConstraint = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: contentOffset)
        
        bubbleWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: bubbleViewWidth)
        bubbleWidthConstraint?.isActive = true
        
        textView.anchor(top: topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
    }
    
}
