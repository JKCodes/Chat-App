//
//  ProfileController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/29/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    fileprivate let profileView = ProfileView()
    
    var user: User? {
        didSet {
            profileView.user = user
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white        
        profileView.delegate = self
        
        setupViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - Setup
extension ProfileController {
    
    func setupViews() {
        
        view.addSubview(profileView)
        profileView.fillSuperview()
    }
}

// MARK: - ProfileViewDelegate

extension ProfileController: ProfileViewDelegate {
    func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfile(user: User) {
        let editVC = EditController()
        editVC.user = user
        navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(editVC, animated: true)
    }
}
