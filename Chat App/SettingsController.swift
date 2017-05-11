//
//  SettingsController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/29/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SettingsController: UICollectionViewController, Alerter {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 80
    
    fileprivate var settings = [SettingsItem]()
    
    var user: User?
    
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
        cell.delegate = self
        cell.setting = settings[indexPath.row]
        cell.index = indexPath.item
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

// MARK: - Delegate for SettingsCell
extension SettingsController: SettingsCellDelegate {
    
    func didEnableSetting(index: Int, onComplete: @escaping (Bool) -> Void) {
        processSettings(index: index, flag: true, onComplete: onComplete)
    }
    
    func didDisableSetting(index: Int, onComplete: @escaping (Bool) -> Void) {
        processSettings(index: index, flag: false, onComplete: onComplete)

    }

    fileprivate func processSettings(index: Int, flag: Bool, onComplete: @escaping (Bool) -> Void) {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        var data = [String: AnyObject]()
        switch index {
        case 0: data[UserDefaultsItem.exactMatch.rawValue] = (flag ? 1 : 0) as AnyObject
        case 1: data[UserDefaultsItem.hideDefault.rawValue] = (flag ? 1 : 0) as AnyObject
        default: return
        }
        
        DatabaseService.shared.saveData(type: .user, data: data, firstChild: uid, secondChild: nil, appendAutoId: false) { [weak self] (error, _) in
            guard let this = self else { return }
            
            if error != nil {
                this.present(this.alertVC(title: "Notice", message: "There was an issue saving data to database. Please try again"), animated: true, completion: nil)
                onComplete(false)
            }
            
            onComplete(true)
        }
    }
}


// MARK: - Setup
extension SettingsController {
    fileprivate func setupData() {
        settings.append(SettingsItem(name: .accountPrivacy, enabled: user?.exactMatch == 1 ? true : false))
        settings.append(SettingsItem(name: .hideFromDefaultSearch, enabled: user?.hideDefault == 1 ? true : false))
        settings.append(SettingsItem(name: .moreUpdates, enabled: true))
    }
}
