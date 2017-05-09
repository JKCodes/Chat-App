//
//  SettingsController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/29/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SettingsController: UICollectionViewController {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 80
    
    fileprivate var settings = [SettingsItem]()
    
    override func viewDidLoad() {
        collectionView?.backgroundColor = UIColor.rgb(r: 245, g: 245, b: 245)
        navigationItem.title = "Settings"
        
        collectionView?.register(SettingsCell.self, forCellWithReuseIdentifier: cellId)
        
        setupData()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingsCell
        cell.title = settings[indexPath.row].name.rawValue
        return cell
    }
}


// MARK: - Delegate for FlowLayout
extension SettingsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 90, left: 16, bottom: 0, right: 16)
    }
}


// MARK: - Setup
extension SettingsController {
    fileprivate func setupData() {
        settings.append(SettingsItem(name: .accountPrivacy))
        settings.append(SettingsItem(name: .hideFromDefaultSearch))
        settings.append(SettingsItem(name: .pushNotifications))
    }
}
