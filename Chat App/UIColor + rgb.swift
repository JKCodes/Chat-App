//
//  UIColor + rgb.swift
//  FacebookFeedClone
//
//  Created by Joseph Kim on 3/23/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(mainRed: Bool) {
        if mainRed {
            self.init(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        } else {
            self.init()
        }
    }
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
