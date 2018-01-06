//
//  EditRouteNameViewController.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/6.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

protocol RouteNameProviderDelegate: class {
    func manager(didGet newRouteName: String)
}

class EditRouteNameViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    weak var delegate: RouteNameProviderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    @objc func save() {
        if let newRouteName = newNameTextField.text {
            self.delegate?.manager(didGet: newRouteName)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }


}
