//
//  HelpController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/29/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HelpController: UIViewController, Alerter {
    
    fileprivate let helpView = HelpView()
    
    var user: User? {
        didSet {
            helpView.user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Help"
        
        setupViews()
        setupDelegates()
    }
}

// MARK: - Setup
extension HelpController {
    
    func setupViews() {
        
        view.addSubview(helpView)
        helpView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func setupDelegates() {
        helpView.delegate = self
        helpView.titleField.delegate = self
        helpView.messageField.delegate = self
    }
}

// MARK: - TextField Delegate
extension HelpController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        helpView.enableSendButton()
    }
}

// MARK: - TextView Delegate
extension HelpController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        helpView.enableSendButton()
        
        textView.layer.borderColor = UIColor.darkGray.cgColor
        animateConstraintTo(value: HelpView.topSpacing * -4)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor(white: 0, alpha: 0.15).cgColor
        animateConstraintTo(value: HelpView.topSpacing)
    }
}

// MARK: - HelpView Delegate
extension HelpController: HelpViewDelegate {
    func handleSendHelp(data: [String : AnyObject]) {
        guard let uid = data["uid"] as? String,
            let email = data["email"] as? String,
            let title = data["title"] as? String,
            let message = data["message"] as? String
            else { return }
        
        if uid.isEmpty || email.isEmpty || title.isEmpty || message.isEmpty {
            present(alertVC(title: "Notice", message: "Please enter both a title and a message."), animated: true, completion: nil)
            return
        }
        
        helpView.disableSendButton()
        DatabaseService.shared.saveData(type: .help, data: data, firstChild: nil, secondChild: nil, appendAutoId: true) { [weak self] (error, _) in
            guard let this = self else { return }
            
            if error != nil {
                this.present(this.alertVC(title: "Error saving data", message: "There was an error while saving data. Please try again."), animated: true, completion: nil)
                return
            }
            this.present(this.alertVC(title: "Success", message: "Your message was sent successfully"), animated: true, completion: nil)
        }
    }
}

// MARK: - Others
extension HelpController {
    fileprivate func animateConstraintTo(value: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            HelpView.sendHelpTopConstraint?.constant = value
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
