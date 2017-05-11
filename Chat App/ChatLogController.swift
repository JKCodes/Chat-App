//
//  ChatLogController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/26/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, Alerter {
    
    fileprivate let cellId = "cellId"
    
    fileprivate var cellHeight: CGFloat = 80
    fileprivate let containerViewHeight: CGFloat = 50
    fileprivate let contentOffset: CGFloat = 8
    fileprivate let messageImageWidth: CGFloat = 200

    fileprivate var containerViewBottomConstraint: NSLayoutConstraint?

    var user: User? {
        didSet {
            guard let firstName = user?.firstName, let lastName = user?.lastName else { return }
            navigationItem.title = "\(firstName) \(lastName)"
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    
    lazy var inputContainerView: ChatInputContainerView = { [weak self] in
        guard let this = self else { return ChatInputContainerView() }
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: this.view.frame.width, height: this.containerViewHeight))
        chatInputContainerView.delegate = this
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CollectionView related
extension ChatLogController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.message = message
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthConstraint?.constant = estimateFrame(text: text).width + contentOffset * 3
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            cellHeight = estimateFrame(text: text).height + contentOffset * 2
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: cellHeight)
    }
    
    fileprivate func estimateFrame(text: String) -> CGRect {
        let size = CGSize(width: ChatMessageCell.cellWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.avenirNextFont(size: ChatMessageCell.textViewFontSize, bold: false)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
}

// MARK: - Delegate for ChatInputContainerView
extension ChatLogController: ChatInputContainerViewDelegate {
    func handleSend() {
        guard let text = inputContainerView.inputTextField.text else { return }
        if text.characters.count < 1 { return }
        let properties: [String: AnyObject] = ["text": text as AnyObject]
        
        sendMessage(properties: properties)
    }
}

// MARK: - Setup
extension ChatLogController {
    
    fileprivate func setupCollectionView() {
        collectionView?.contentInset = UIEdgeInsets(top: contentOffset, left: 0, bottom: contentOffset, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    fileprivate func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    fileprivate func setupCell(cell: ChatMessageCell, message: Message) {
        guard let urlSting = user?.profileImageUrl else { return }
        cell.profileImageView.loadImage(urlString: urlSting)
        
        if message.fromId == AuthenticationService.shared.currentId() {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleRightConstraint?.isActive = true
            cell.bubbleLeftConstraint?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = .rgb(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleRightConstraint?.isActive = false
            cell.bubbleLeftConstraint?.isActive = true
        }
    }
}

// MARK: - Handlers
extension ChatLogController {
    
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: - Others
extension ChatLogController {

    fileprivate func observeMessages() {
        guard let fromId = AuthenticationService.shared.currentId(), let toId = user?.uid else { return }
        
        DatabaseService.shared.retrieve(type: .userMessages, eventType: .childAdded, firstChild: fromId, secondChild: toId, propagate: nil, sortBy: nil) { (snapshot) in
            let messageId = snapshot.key
            
            DatabaseService.shared.retrieveOnce(type: .message, eventType: .value, firstChild: messageId, secondChild: nil, propagate: nil, sortBy: nil, onComplete: { [weak self] (snapshot) in
                guard let this = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
                this.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: this.messages.count - 1, section: 0)
                    this.collectionView?.reloadData()
                    this.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    fileprivate func sendMessage(properties: [String: AnyObject]) {
        guard let toId = user?.uid, let fromId = AuthenticationService.shared.currentId() else { return }
        
        var values = ["toId": toId, "fromId": fromId, "timestamp": "\(Date().timeIntervalSince1970)"] as [String: AnyObject]
        properties.forEach({values[$0] = $1 })
        
        DatabaseService.shared.saveData(type: .message, data: values, firstChild: nil, secondChild: nil, appendAutoId: true) { [weak self] (error, ref) in
            guard let this = self, let ref = ref else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "Error saving to database", message: error), animated: true, completion: nil)
            }
            
            values = [ref.key: 1] as [String: AnyObject]
            
            DatabaseService.shared.saveData(type: .userMessages, data: values, firstChild: fromId, secondChild: toId, appendAutoId: false, fan: true, onComplete: { (error, _) in
                if let error = error {
                    this.present(this.alertVC(title: "Error saving to database", message: error), animated: true, completion: nil)
                }
                
                this.inputContainerView.inputTextField.text = nil
            })
        }
    }
}
