//
//  RoutesTableViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/28.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import Firebase

class RoutesTableViewController: UITableViewController {

    var pathId: pathId?
    var pathIds: [pathId] = []
    
    let mapViewController = MapViewController()
    
    //Route screen shot
    var routeImageView: UIImageView?
    
    //routes for coredata
    var items: [Item] = []
    
    //for update route name
    var nameUpdateCount: Int = 0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RouteTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "routeCell")
        
        //add addANewArticle navigationItem at rightside
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addANewRoute(sender:)))
        

        self.view.backgroundColor = .white
        setupHeader()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapViewController.routeDelegate = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupStatusBarColor()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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
                
                let distance = Int(route.distance)
                cell.distance.text = "\(distance) m"
                
                if let newRouteName = route.name {
                    cell.routeNameTextField.text = newRouteName
                }
                
                cell.saveButton.addTarget(self, action: #selector(save(sender:)), for: .touchUpInside)
                
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = items[indexPath.row]
        let arFollowerViewController = ARFollowerViewController()
        if let id = route.id {
            arFollowerViewController.currentPathId = id
        } else {
            // error message
            print("path not existed")
        }
        present(arFollowerViewController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let route = items[indexPath.row]
        if editingStyle == .delete {
            guard let pathId = route.id else {
                print("route not exist")
                return
            }
            showDeleteAlert(with: pathId)
        }
    }
    
    @objc func save(sender: UIButton) {
        if let cell = sender.superview?.superview as? RouteTableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            guard let cellIndexPath = indexPath else {
                print("indexpath not exist")
                return
            }
            
            let route = items[cellIndexPath.row]
            
            if let pathId = route.id {
                let fetchResults = CoreDataHandler.filterData(selectedItemId: pathId)
                if let fetchResults =  fetchResults {
                    let managedObject = fetchResults[0]
                    if let newRouteName = cell.routeNameTextField.text {
                        CoreDataHandler.updateObject(object: managedObject, name: newRouteName)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func showDeleteAlert(with pathId: pathId) {
        
        let alert = UIAlertController(
            title: NSLocalizedString("Are you sure to delete this route?", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        let delete = UIAlertAction(
            title: NSLocalizedString("Delete", comment: ""),
            style: .destructive,
            handler: { action in self.deletePath(with: pathId) }
        )
        
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func deletePath(with pathId: pathId) {
        
        //delete from firebase
        let pathRef = Database.database().reference().child("paths").child(pathId)
        pathRef.removeValue()
        
        //delete from coredata
        if let fetchResults = CoreDataHandler.filterData(selectedItemId: pathId) {
            let resultToBeDeleted = fetchResults[0]
            CoreDataHandler.deleteObject(item: resultToBeDeleted)
        } else {
            print("route not existed")
        }
        
        DispatchQueue.main.async {
            self.items = CoreDataHandler.fetchObject()!
            self.tableView.reloadData()
        }
    }

    @objc func addANewRoute(sender: UIBarButtonItem) {
        let positioningViewController = PositioningViewController()
        let navigationController = TransparentNavigationController(rootViewController: positioningViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func share(sender: UIButton) {
        
        // TODO: revise tag to super super
        let index = sender.tag
        let route = items[index]
        
        if let id = route.id {
            let activityViewController = UIActivityViewController(activityItems: [id], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }

    }
    
    // MARK: Setup
    
    func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = Palette.seaBlue
    }
    
    func setupHeader() {
        self.view.backgroundColor = Palette.mystic
        let headerView = EntryListHeaderView.create()
        
        headerView.titleLabel.text = NSLocalizedString("Routes", comment: "")
        headerView.addButton.addTarget(self, action: #selector(addANewRoute(sender:)), for: .touchUpInside)
        headerView.cancelButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
    }

    
}

extension RoutesTableViewController: RouteProviderDelegate {
    
    func didGet(routeImageView: UIImageView) {
        
        self.routeImageView?.image = routeImageView.image
        
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

