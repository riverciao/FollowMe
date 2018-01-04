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
    
    static let baliHai = UIColor(r: 145, g: 169, b: 180)
    
    static let mystic = UIColor(r: 228, g: 237, b: 238)
    
    static let silverSand = UIColor(r: 187, g: 194, b: 195)
    
    static let abbey = UIColor(r: 83, g: 86, b: 86)
    
    static let duckFeather = UIColor(r: 255, g: 201, b: 10)
    
    static let duckBeak = UIColor(r: 255, g: 79, b: 25)
    
    static let seaBlue = UIColor(r: 17, g: 143, b: 228)
    
    static let dandelion = UIColor(r: 255, g: 233, b: 129)
    
}

