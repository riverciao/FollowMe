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
        
        let positioningViewController = PositioningViewController()
        present(positioningViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func followRouteButton(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
