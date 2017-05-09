//
//  HelpView.swift
//  Chat App
//
//  Created by Joseph Kim on 5/8/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol HelpViewDelegate: class {
    func handleSendHelp(data: [String: AnyObject])
}

class HelpView: UIView {
    
    fileprivate let contentSpacing: CGFloat = 16
    internal static let topSpacing: CGFloat = 32
    fileprivate let defaultHeight: CGFloat = 30
    fileprivate let leftRightSpacing: CGFloat = 50
    fileprivate let textViewHeight: CGFloat = 200
    
    internal static var sendHelpTopConstraint: NSLayoutConstraint?
    
    weak var delegate: HelpViewDelegate?
    
    var user: User? {
        didSet {
            guard let email = user?.email else { return }
            emailField.text = email
            emailField.backgroundColor = .lightGray
            emailField.textColor = .darkGray
            emailField.isUserInteractionEnabled = false
        }
    }
    
    let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 22, bold: true)
        label.text = "Need help?"
        return label
    }()
    
    let emailField: UITextField = {
        return HelpView.returnTemplateTextField(placeholder: "Email")
    }()
    
    let titleField: UITextField = {
        return HelpView.returnTemplateTextField(placeholder: "Title")
    }()
    
    let messageField: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.avenirNextFont(size: 14, bold: false)
        tv.backgroundColor = UIColor.rgb(r: 250, g: 250, b: 250)
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 5
        tv.layer.borderColor = UIColor(white: 0, alpha: 0.15).cgColor
        return tv
    }()
    
    lazy var sendButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.avenirNextFont(size: 14, bold: true)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(mainRed: true)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
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
extension HelpView {
    
    fileprivate func setupViews() {
        addSubview(mainTitleLabel)
        addSubview(emailField)
        addSubview(titleField)
        addSubview(messageField)
        addSubview(sendButton)
        
        
        HelpView.sendHelpTopConstraint = mainTitleLabel.anchorAndReturn(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: contentSpacing * 2, leftConstant: leftRightSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: defaultHeight)[0]
        emailField.anchor(top: mainTitleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing * 2, leftConstant: leftRightSpacing, bottomConstant: 0, rightConstant: leftRightSpacing, widthConstant: 0, heightConstant: defaultHeight)
        titleField.anchor(top: emailField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: leftRightSpacing, bottomConstant: 0, rightConstant: leftRightSpacing, widthConstant: 0, heightConstant: defaultHeight)
        messageField.anchor(top: titleField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: leftRightSpacing, bottomConstant: 0, rightConstant: leftRightSpacing, widthConstant: 0, heightConstant: textViewHeight)
        sendButton.anchor(top: messageField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: contentSpacing, leftConstant: leftRightSpacing, bottomConstant: 0, rightConstant: leftRightSpacing, widthConstant: 0, heightConstant: defaultHeight * 1.5)
        
    }
    
}

// MARK: - Handlers
extension HelpView {
    func handleSend() {
        guard let uid = AuthenticationService.shared.currentId(),
            let email = emailField.text,
            let title = titleField.text,
            let message = messageField.text
            else { return }
        
        let data = ["uid": uid, "email": email, "title": title, "message": message] as [String: AnyObject]
        
        delegate?.handleSendHelp(data: data)
    }
}

// MARK: - Others
extension HelpView {
    fileprivate static func returnTemplateTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.font = UIFont.avenirNextFont(size: 14, bold: false)
        tf.backgroundColor = UIColor.rgb(r: 250, g: 250, b: 250)
        tf.borderStyle = .roundedRect
        tf.placeholder = placeholder
        return tf
    }
    
    func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.backgroundColor = UIColor(mainRed: true)
    }
    
    func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.backgroundColor = .darkGray
    }
}
