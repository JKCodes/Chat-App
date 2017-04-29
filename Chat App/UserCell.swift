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
    fileprivate let timeLabelWidth: CGFloat = 100
    fileprivate let timeLabelRightSpacing: CGFloat = 20
    
    var message: Message? {
        
        didSet {
            setupNameAndProfileImage()
            
            messageButton.setImage(nil, for: .normal)
            
            if let chatPartnerId = message?.toId {
                
                var displayText = ""
                
                if let text = message?.text {
                    displayText = text
                }
                
                detailTextLabel?.text = chatPartnerId == AuthenticationService.shared.currentId() ? displayText : "You: \(displayText)"
                
            }
            
            if let timeStamp = message?.timestamp, let seconds = Double(timeStamp) {
                let timestampeDate = Date(timeIntervalSince1970: seconds)
                let elapsedTimeInSeconds = Date().timeIntervalSince(timestampeDate)
                let secondsInADay: TimeInterval = 60 * 60 * 24
                
                let dateFormatter = DateFormatter()
                
                if elapsedTimeInSeconds > 7 * secondsInADay {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondsInADay {
                    dateFormatter.dateFormat = "EEE"
                } else {
                    dateFormatter.dateFormat = "hh:mm:ss a"
                }
                
                timeLabel.text = dateFormatter.string(from: timestampeDate)
            }
            
        }
    }
    
    
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
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
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
        addSubview(timeLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset * 2, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
        profileImageView.anchorCenterYToSuperview()
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: contentOffset * 2.5, widthConstant: messageButtonLength, heightConstant: messageButtonLength)
        messageButton.anchorCenterYToSuperview()
        timeLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: contentOffset * 2, leftConstant: 0, bottomConstant: 0, rightConstant: timeLabelRightSpacing, widthConstant: timeLabelWidth, heightConstant: 0)
        
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
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: id, secondChild: nil, propagate: nil, sortBy: nil, onComplete: { [weak self] (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    guard let firstName = dictionary["firstName"], let lastName = dictionary["lastName"], let username = dictionary["username"] else { return }
                    self?.textLabel?.text = "\(firstName) \(lastName) (@\(username))"
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self?.profileImageView.loadImage(urlString: profileImageUrl)
                    }
                    
                }
            })
        }
    }
    
    fileprivate func setupCell() {
        textLabel?.font = UIFont.avenirNextFont(size: 20, bold: true)
        detailTextLabel?.font = UIFont.avenirNextFont(size: 14, bold: false)
        detailTextLabel?.textColor = UIColor(white: 0, alpha: 0.5)
        
    }
}
