//
//  FollowerEntranceViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class FollowerEntranceViewController: UIViewController {

    
    @IBOutlet weak var invitationCodeTextField: UITextField!
    
    @IBAction func goToARButton(_ sender: Any) {
        
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

}
