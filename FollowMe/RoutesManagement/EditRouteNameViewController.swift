//
//  EditRouteNameViewController.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/6.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit
import CoreData

protocol RouteNameProviderDelegate: class {
    func manager(didGet newRouteName: String)
}

class EditRouteNameViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    weak var delegate: RouteNameProviderDelegate?
    var pathId: pathId?
    
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
            if let pathId = pathId {
                let fetchResults = CoreDataHandler.filterData(selectedItemId: pathId)
                if let fetchResults =  fetchResults {
                    let managedObject = fetchResults[0]
                    CoreDataHandler.updateObject(object: managedObject, name: newRouteName)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }


}
