//
//  TransparentNavigationController.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/5.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class TransparentNavigationController: BaseNavigationController {
    
    // MARK: Init
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        setUp()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setUp()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
        
    }
    
    // MARK: Appearance
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    // MARK: Set Up
    
    private func setUp() {
        
        navigationBar.barTintColor = .clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        
    }
    
}
