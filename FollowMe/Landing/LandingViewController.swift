//
//  LandingViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import YXWaveView

class LandingViewController: UIViewController {
    
    @IBOutlet weak var newRouteButton: UIButton!
    @IBOutlet weak var invitationCodeButton: UIButton!
    fileprivate var waveView: YXWaveView?

    
    @IBAction func setRouteButton(_ sender: Any) {
        
        let routesTableViewController = RoutesTableViewController()
        let navigationController = UINavigationController(rootViewController: routesTableViewController)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func followRouteButton(_ sender: Any) {
        
        let followerEntranceViewController = FollowerEntranceViewController()
        present(followerEntranceViewController, animated: true, completion: nil)
        
    }
    
    lazy var landingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "landing-walking-bird")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Palette.mystic
        setupNewRouteButton()
        setupInvitationCodeButton()
        
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStatusBarColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLandingImageView()
        setupWaterView()
    }
    
    // MARK: - Setup
    
    func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = Palette.duckFeather
    }
    
    func setupWaterView() {
        
        let waterHeight: CGFloat = 220
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: view.frame.size.height - waterHeight)
        waveView = YXWaveView(frame: frame, waterColor: Palette.seaBlue)
        
        if let waveView = waveView {
            waveView.waveHeight = 12
            
            // declare waterView
            let waterView = UIView()
            waterView.frame = CGRect(x: 0, y: view.frame.size.height - waterHeight, width: view.frame.size.width, height: waterHeight)
            waterView.backgroundColor = Palette.seaBlue
            
            // add waveView
            self.view.insertSubview(waveView, aboveSubview: landingImageView)
            self.view.insertSubview(waterView, aboveSubview: landingImageView)
            
            // Start wave
            waveView.start()
        }
    }
    
    func setupLandingImageView() {
        view.addSubview(landingImageView)
        
        landingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        landingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        landingImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        landingImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        view.sendSubview(toBack: landingImageView)
    }
    
    func setupNewRouteButton() {
        newRouteButton.translatesAutoresizingMaskIntoConstraints = false
        
        newRouteButton.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 32)
        newRouteButton.setTitleColor( .white, for: .normal)
        newRouteButton.backgroundColor = Palette.duckBeak
        newRouteButton.layer.cornerRadius = 8
    }
    
    func setupInvitationCodeButton() {
        invitationCodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        invitationCodeButton.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 32)
        invitationCodeButton.setTitleColor( .white, for: .normal)
        invitationCodeButton.backgroundColor = Palette.duckBeak
        invitationCodeButton.layer.cornerRadius = 8
        
    }

}
