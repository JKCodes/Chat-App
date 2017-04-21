//
//  UIFont + avenirNextFont.swift
//  Chat App
//
//  Created by Joseph Kim on 4/21/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

extension UIFont {
    static func avenirNextFont(size: CGFloat, bold: Bool) -> UIFont {
        if bold {
            return UIFont(name: "Avenir Next-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        } else {
            return UIFont(name: "Avenir Next", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
}
