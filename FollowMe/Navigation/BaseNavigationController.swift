//
//  BaseNavigationController.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/5.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    // MARK: Appearance
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return .all
        default:
            return .portrait
        }
        
    }
    
}

