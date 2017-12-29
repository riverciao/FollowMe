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
    var pathIds: [pathId] = []
    
    let mapViewController = MapViewController()
    
    //Route screen shot
    var routeImageView: UIImageView? {
        didSet {
            print("RoutesTableViewController--routeImageView\(routeImageView)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //add addANewArticle navigationItem at rightside
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addANewRoute(sender:)))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapViewController.routeDelegate = self
        
        // pass pathId back
        // TODO: - Coredata or Firebase to cach data
        if let pathId = pathId {
            pathIds.insert(pathId, at: 0)
        }
        
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

extension RoutesTableViewController: RouteDelegate {
    func didGet(routeImageView: UIImageView) {
        
        self.routeImageView = routeImageView
        
        print("OOOOrouteImageView\(self.routeImageView)")
        
    }
    
}
