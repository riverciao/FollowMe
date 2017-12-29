//
//  UIViewExtension.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/29.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit


extension UIView {
    
    func addAnnotation(image: UIImage,to point: CGPoint) {
        
        let size = CGSize(width: 15, height: 15)
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        let imageView = UIImageView(frame: CGRect(origin: origin, size: size))
        imageView.image = image
        self.addSubview(imageView)
        
    }
}
