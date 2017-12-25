//
//  ARFollowerViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/24.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import ARKit
import MapKit
import Firebase

class ARFollowerViewController: UIViewController, SceneLocationViewDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    var startNode: LocationSphereNode?
    
    //Existed Path Property
    var existedStartNode: LocationSphereNode?
    var existedPathNode: LocationSphereNode?
    
    
    
    //property for current location coordinate to start node 3D vector
    var currentLocationCoordinateForARSetting: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.locationDelegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneLocationView.run()
        
        fetchPath()

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneLocationView.pause()
        
    }

    
    private func fetchPath() {
        
        Database.database().reference().child("paths").observe( .childAdded) { (snapshot) in
            
            let pathId = snapshot.key
            let pathRef = Database.database().reference().child("paths").child(pathId)
            
            pathRef.observeSingleEvent(of: .value, with: { (pathSnapshot) in
                
                if let dictionary = pathSnapshot.value as? [String: AnyObject] {
                    
                    guard let startNode = dictionary["start-node"] as? [String: AnyObject] else { return }
                    
                    guard let latitude = startNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = startNode[NodeCoordinate.Schema.longitude] as? Double, let altitude = startNode[NodeCoordinate.Schema.altitude] as? Double else { return }
                    
//                    let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: 26)
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    self.existedStartNode = LocationSphereNode(location: location, nodeType: .start)
                    
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedStartNode!)
                    
                    let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes")
                    
                    pathNodesRef.observe( .childAdded, with: { (pathNodesSnapshot) in
                        
                        let pathNodesId = pathNodesSnapshot.key
                        
                        let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes").child(pathNodesId)
                        
                        pathNodesRef.observeSingleEvent(of: .value, with: { (positionSnapshot) in
                            
                            if let dictionary = positionSnapshot.value as? [String: Any] {
                                
                                guard let latitude = dictionary[NodeCoordinate.Schema.latitude] as? Double, let longitude = dictionary[NodeCoordinate.Schema.longitude] as? Double, let altitude = dictionary[NodeCoordinate.Schema.altitude] as? Double else { return }
                                
//                                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: 26)
                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                
                                self.existedPathNode = LocationSphereNode(location: location, nodeType: .path)
                                
                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedPathNode!)
                                
                            }
                            
                        }, withCancel: nil)
                        
                    }, withCancel: nil)
                    
                }
                
            }, withCancel: nil)
            
        }
        
    }


    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {

        if let name = locationNode.name {
            switch name {
            case "start":
                
                if let position = sceneLocationView.currentScenePosition() {
                    
                    let x = locationNode.position.x
                    
                    let z = locationNode.position.z
                    
                    let targetNode = Node(nodeType: .start)
                    
                    targetNode.position = SCNVector3(x, position.y, z)
                    
                    self.sceneLocationView.scene.rootNode.addChildNode(targetNode)
                    
                }
                
                print("start")
                
            case "path":
                
                if let position = sceneLocationView.currentScenePosition() {
                    
                    let x = locationNode.position.x
                    
                    let z = locationNode.position.z
                    
                    let targetNode = Node(nodeType: .path)
                    
                    targetNode.position = SCNVector3(x, position.y, z)
                    
                    self.sceneLocationView.scene.rootNode.addChildNode(targetNode)
                }
                
                print("path")
                
            case "end": print("end")
            default: print("XX")
            }
        }

    }
}
