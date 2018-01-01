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
    var routeImageView: UIImageView?
    
    //routes for coredata
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RouteTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "routeCell")
        
        //add addANewArticle navigationItem at rightside
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addANewRoute(sender:)))
        
        self.view.backgroundColor = Palette.mystic

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapViewController.routeDelegate = self
        
        if let items = CoreDataHandler.fetchObject() {
            self.items = items
        }
        
        self.tableView.reloadData()
        
        // pass pathId back
        // TODO: - Coredata or Firebase to cach data
        if let pathId = pathId {
            pathIds.insert(pathId, at: 0)
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var routeCell = RouteTableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as? RouteTableViewCell {
            
            let route = items[indexPath.row]
            cell.shareButtonOutlet.tag = indexPath.row
            
            if items.count > indexPath.row {
                
//                if let distance = route.id {
//                    cell.routeName.text = id
//                }
                
                cell.shareButtonOutlet.addTarget(self, action: #selector(share(sender:)), for: .touchUpInside)
                
                if let imageData = route.image {
                    if let image = UIImage(data: imageData) {
                        cell.routeImageView.image = image
                    }
                }
            }
            
            routeCell = cell
        }
        return routeCell
    }

    @objc func addANewRoute(sender: UIBarButtonItem) {
        let positioningViewController = PositioningViewController()
        self.navigationController?.pushViewController(positioningViewController, animated: true)
    }
    
    @objc func share(sender: UIButton) {
        print("234")
        
        let index = sender.tag
        let route = items[index]
        
        if let id = route.id {
            let activityViewController = UIActivityViewController(activityItems: [id], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }

    }
    

    

    
}

extension RoutesTableViewController: RouteProviderDelegate {
    
    func didGet(routeImageView: UIImageView) {
        
        self.routeImageView?.image = routeImageView.image
        
    }
}
