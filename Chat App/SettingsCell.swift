//
//  SettingsCell.swift
//  Chat App
//
//  Created by Joseph Kim on 5/8/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SettingsCell: BaseCollectionViewCell {
    
    fileprivate var enabled: Bool = false
    fileprivate let defaultSpacing: CGFloat = 16
    fileprivate let viewHeight: CGFloat = 30
    fileprivate let enableViewWidth: CGFloat = 60
    
    fileprivate var circleViewLeftConstraint: NSLayoutConstraint!
    
    
    var title: String? {
        didSet {
            nameLabel.text = title
        }
    }
    
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirNextFont(size: 16, bold: true)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var enableView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .red
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapped)))
        return view
    }()
    
    fileprivate lazy var enableCircle: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .white
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        return view
    }()
    
    
    override func setupViews() {
        setupCell()
        setupSubviews()
        setupTitle()
        setupEnableViews()
    }
}

// MARK: - Setups
extension SettingsCell {
    fileprivate func setupCell() {
        backgroundColor = .white
        layer.borderColor = UIColor(white: 0, alpha: 0.15).cgColor
        layer.borderWidth = 0.5
    }
    
    fileprivate func setupSubviews() {
        addSubview(nameLabel)
        addSubview(enableView)
        enableView.addSubview(enableCircle)

    }
    
    fileprivate func setupTitle() {
        nameLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: enableView.leftAnchor, topConstant: 0, leftConstant: defaultSpacing, bottomConstant: 0, rightConstant: defaultSpacing * 2, widthConstant: 0, heightConstant: 0)
        nameLabel.anchorCenterYToSuperview()
    }
    
    fileprivate func setupEnableViews() {
        enableView.layer.cornerRadius = viewHeight / 2
        enableCircle.layer.cornerRadius = viewHeight / 2
        enableCircle.layer.borderWidth = 1
        enableCircle.layer.borderColor = UIColor.lightGray.cgColor
        
        enableView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: defaultSpacing, widthConstant: enableViewWidth, heightConstant: viewHeight)
        enableView.anchorCenterYToSuperview()
        
        circleViewLeftConstraint = enableCircle.anchorAndReturn(top: nil, left: enableView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: viewHeight, heightConstant: viewHeight)[0]
        enableCircle.anchorCenterYToSuperview()
    }
}

// MARK: - Handlers
extension SettingsCell {
    func handleTapped() {
        enabled ? disableSetting() : enableSetting()
    }
    
    func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.left: disableSetting()
        case UISwipeGestureRecognizerDirection.right: enableSetting()
        default: return
        }
    }
}

// MARK: - Others
extension SettingsCell {
    fileprivate func enableSetting() {
        enabled = true
        enableView.backgroundColor = .green
        animateConstraint(to: 30)
    }
    
    fileprivate func disableSetting() {
        enabled = false
        enableView.backgroundColor = .red
        animateConstraint(to: 0)
    }
    
    fileprivate func animateConstraint(to value: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.circleViewLeftConstraint.constant = value
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
