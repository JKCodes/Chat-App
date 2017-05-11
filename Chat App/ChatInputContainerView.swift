//
//  ChatInputContainerView.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol ChatInputContainerViewDelegate: class {
    func handleSend()
}

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    fileprivate let buttonWidth: CGFloat = 80
    fileprivate let buttonHeight: CGFloat = 50
    fileprivate let contentOffset: CGFloat = 8
    fileprivate let inputTextFieldHeight: CGFloat = 50
    fileprivate let separatorHeight: CGFloat = 1
    fileprivate let uploadImageLength: CGFloat = 44
    
    weak var delegate: ChatInputContainerViewDelegate? {
        didSet {
            sendButton.addTarget(delegate, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
        }
    }
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    lazy var inputTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Type Something..."
        tf.font = UIFont.avenirNextFont(size: 14, bold: false)
        tf.delegate = this
        return tf
        }()
    
    let separatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = .rgb(r: 220, g: 220, b: 220)
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(separatorView)
        
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonHeight)
        sendButton.anchorCenterYToSuperview()
        inputTextField.anchor(top: nil, left: leftAnchor, bottom: nil, right: sendButton.leftAnchor, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: inputTextFieldHeight)
        inputTextField.anchorCenterYToSuperview()
        separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: separatorHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.handleSend()
        return true
    }
}
