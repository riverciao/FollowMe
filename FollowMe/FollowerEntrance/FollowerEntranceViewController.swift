//
//  FollowerEntranceViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class FollowerEntranceViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var goToARButtonOutlet: UIButton = {
        let button = UIButton()
        button.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 80))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Palette.duckBeak
        button.setTitleColor(Palette.mystic, for: .normal)
        button.setTitle("GO", for: .normal)
        button.titleLabel?.font = UIFont(name: "ARCADECLASSIC", size: 36)
        button.layer.cornerRadius = button.bounds.height / 2
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "icon-walking-bird"), for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsetsMake(70, 70, 70, 70)
        button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundColor(color: Palette.seaBlue, forState: .highlighted)
        button.addTarget(self, action: #selector(goToARButton), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet weak var invitationCodeTextField: UITextField!
    
    @objc func goToARButton() {
        guard let pathId: pathId = invitationCodeTextField.text else {
            
            //deal with empty text field
            
            return
            
        }
        
        let arFollowerViewController = ARFollowerViewController()
        
        arFollowerViewController.currentPathId = pathId
        
        present(arFollowerViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        self.view.backgroundColor = Palette.dandelion
        
        //setupCancelButton
        let cancelImage = #imageLiteral(resourceName: "button_close").withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(cancelImage, for: .normal)
        cancelButton.tintColor = Palette.baliHai
        
        //setup title
        titleLabel.textColor = Palette.seaBlue
        
        //setup goToARButtonOutlet
        view.addSubview(goToARButtonOutlet)
        
        goToARButtonOutlet.topAnchor.constraint(equalTo: invitationCodeTextField.bottomAnchor, constant: 40).isActive = true
        goToARButtonOutlet.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goToARButtonOutlet.widthAnchor.constraint(equalToConstant: 80).isActive = true
        goToARButtonOutlet.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }

}
