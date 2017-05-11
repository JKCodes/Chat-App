//
//  MenuController.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol MenuControllerDelegate: class {
    func showController(menuItem: MenuItem)
}

class MenuController: NSObject {
    
    fileprivate let cellId = "cellId"
    fileprivate let headerId = "headerId"
    fileprivate let menuItemCellSize: CGFloat = 88
    fileprivate let menuWidthRatio: CGFloat = 0.80
    fileprivate let cellSpacing: CGFloat = 20
    fileprivate let headerHeight: CGFloat = 130
    
    fileprivate let window = UIApplication.shared.keyWindow
    fileprivate var header: MenuHeader!
    
    var user: User? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: MenuControllerDelegate?
    
    let blackView = UIView()
    
    let menuItems: [MenuItem] = {
        return [
            MenuItem(name: .profile, image: #imageLiteral(resourceName: "profile")),
            MenuItem(name: .help, image: #imageLiteral(resourceName: "help")),
            MenuItem(name: .settings, image: #imageLiteral(resourceName: "settings")),
            MenuItem(name: .logout, image: #imageLiteral(resourceName: "logout"))
        ]
    }()
    
    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = UIColor.rgb(r: 0, g: 38, b: 88)
        return cv
    }()
    
    override init() {
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MenuItemCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(MenuHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }
}

// MARK: - CollectionView Related
extension MenuController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuItemCell
        
        cell.menuItem = menuItems[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: menuItemCellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.item]
        handleDismiss(menuItem: menuItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! MenuHeader
        header.user = user
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let window = window else { return CGSize(width: 0, height: 0) }
        return CGSize(width: window.frame.width * menuWidthRatio, height: headerHeight)
    }
}

// MARK: - Handlers
extension MenuController {
    func handleBlackViewTap() {
        handleDismiss(menuItem: MenuItem(name: .cancel, image: #imageLiteral(resourceName: "logout")))
    }
    
    func handleDismiss(menuItem: MenuItem) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            guard let window = self.window else { return }
            
            self.blackView.alpha = 0
            self.collectionView.frame = CGRect(x: -window.frame.width * self.menuWidthRatio, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }) { [weak self] (completed ) in
            if menuItem.name != .cancel {
                self?.delegate?.showController(menuItem: menuItem)
            }
            
            self?.collectionView.removeFromSuperview()
            self?.blackView.removeFromSuperview()
        }
    }
}

extension MenuController {
    internal func showMenu() {
        guard let window = window else { return }
        
        let height = window.frame.height
        let width = window.frame.width * menuWidthRatio
        let x = width
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBlackViewTap)))
        
        window.addSubview(blackView)
        window.addSubview(collectionView)
        
        collectionView.frame = CGRect(x: -x, y: 0, width: width, height: height)
        
        blackView.frame = window.frame
        blackView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }, completion: nil)
    }
}
