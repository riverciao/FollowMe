//
//  RoutesTableViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {

    var pathId: pathId?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add addANewArticle navigationItem at rightside
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addANewRoute(sender:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("pathIdRoutesTableViewController\(pathId)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    @objc func addANewRoute(sender: UIBarButtonItem) {
        let positioningViewController = PositioningViewController()
        self.navigationController?.pushViewController(positioningViewController, animated: true)
    }
    
}
