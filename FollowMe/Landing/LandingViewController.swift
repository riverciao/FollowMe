//
//  LandingViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    @IBOutlet weak var newRouteButton: UIButton!
    @IBOutlet weak var invitationCodeButton: UIButton!
    
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

        self.view.backgroundColor = Palette.seaBlue
        setupNewRouteButton()
        setupInvitationCodeButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupNewRouteButton() {
        newRouteButton.translatesAutoresizingMaskIntoConstraints = false
        
        newRouteButton.setTitleColor( .white, for: .normal)
        newRouteButton.backgroundColor = Palette.duckBeak
        newRouteButton.layer.cornerRadius = 8
    }
    
    func setupInvitationCodeButton() {
        invitationCodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        invitationCodeButton.setTitleColor( .white, for: .normal)
        invitationCodeButton.backgroundColor = Palette.duckBeak
        invitationCodeButton.layer.cornerRadius = 8
        
    }

}
