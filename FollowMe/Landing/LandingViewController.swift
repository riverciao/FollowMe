//
//  LandingViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    
    @IBAction func setRouteButton(_ sender: Any) {
        
        let routesTableViewController = RoutesTableViewController()
        let navigationController = UINavigationController(rootViewController: routesTableViewController)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func followRouteButton(_ sender: Any) {
        
        let followerEntranceViewController = FollowerEntranceViewController()
        present(followerEntranceViewController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(r: 228, g: 237, b: 238)
    }

}
