//
//  UIColor.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/1.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}



struct Palette {
    
    static let baliHai = UIColor(r: 245, g: 169, b: 180)
    
    static let mystic = UIColor(r: 228, g: 237, b: 238)
    
    static let abbey = UIColor(r: 83, g: 86, b: 86)
    
    static let duckFeather = UIColor(r: 255, g: 233, b: 129)
    
    static let duckBeak = UIColor(r: 255, g: 79, b: 25)
    
}

