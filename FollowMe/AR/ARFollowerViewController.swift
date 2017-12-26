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
    var existedStartNode: LocationNode?
    var existedPathNode: LocationNode?
    var existedPathNodes: [LocationNode] = []
    var existedEndNode: LocationNode?
    var nowLoadingPathId: String = ""
    
    //x, z for 3DVector converted from GPS
    var x: Float?
    var z: Float?
    
    
    //property for current location coordinate to start node 3D vector
    var currentLocationCoordinateForARSetting: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.locationDelegate = self
        
        //add touch gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneLocationView.addGestureRecognizer(tapGestureRecognizer)

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
    
    @objc func handleTap(sender: UIGestureRecognizer) {
        
        let sceneViewTappedOn = sender.view as!  SceneLocationView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTest.isEmpty {
            
            print("hit nothing")
            
        } else {
            
            if let node = hitTest.first?.node as? Node {
                
                print("OOOOO\(node.nodeType)")
            
            }
            
        }
        
    }
    
    private func retrieveStartNode(from dictionary: [String: AnyObject]) {
        
        //retrieve start node
        guard let startNode = dictionary["start-node"] as? [String: AnyObject] else { return }
        
        guard let latitude = startNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = startNode[NodeCoordinate.Schema.longitude] as? Double, let altitude = startNode[NodeCoordinate.Schema.altitude] as? Double else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.existedStartNode = LocationNode(location: location)
        
        self.existedStartNode?.name = "start"
        
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedStartNode!)
        
    }
    
    private func retrieveEndNode(from dictionary: [String: AnyObject]) {
        
        //retrieve start node
        guard let endNode = dictionary["end-node"] as? [String: AnyObject] else { return }
        
        guard let latitude = endNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = endNode[NodeCoordinate.Schema.longitude] as? Double else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.existedEndNode = LocationNode(location: location)
        
        self.existedEndNode?.name = "end"
        
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedEndNode!)
        
    }
    
    typealias pathId = String
    
    private func retrievePathNodes(with pathId: pathId) {
        
        let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes")
        
        pathNodesRef.observe( .childAdded, with: { (pathNodesSnapshot) in
            
            let pathNodesId = pathNodesSnapshot.key
            
            let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes").child(pathNodesId)
            
            pathNodesRef.observeSingleEvent(of: .value, with: { (positionSnapshot) in
                
                if let dictionary = positionSnapshot.value as? [String: Any] {
                    
                    guard let latitude = dictionary[NodeCoordinate.Schema.latitude] as? Double, let longitude = dictionary[NodeCoordinate.Schema.longitude] as? Double, let altitude = dictionary[NodeCoordinate.Schema.altitude] as? Double else { return }
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    self.existedPathNode = LocationNode(location: location)
                    
                    self.existedPathNode?.name = "path"
                    
                    self.existedPathNodes.insert(self.existedPathNode!, at: 0)
                    
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedPathNode!)
                    
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }

    
    private func fetchPath() {
        
        Database.database().reference().child("paths").observe( .childAdded) { (snapshot) in
            
            let pathId = snapshot.key
            let pathRef = Database.database().reference().child("paths").child(pathId)
            
            pathRef.observeSingleEvent(of: .value, with: { (pathSnapshot) in
                
                if let dictionary = pathSnapshot.value as? [String: AnyObject] {
                    
                    self.retrieveStartNode(from: dictionary)
                    
                    self.retrieveEndNode(from: dictionary)
                    
                    self.retrievePathNodes(with: pathId)

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
    
    private func draw(_ locationNode: LocationNode, inNodeType nodeType: NodeType) {
        
        if self.x != locationNode.position.x || self.z != locationNode.position.z {
            
            self.x = locationNode.position.x
            
            self.z = locationNode.position.z
            
            if let position = sceneLocationView.currentScenePosition(), let x = self.x, let z = self.z {
                
                let targetNode = Node(nodeType: nodeType)
                
                targetNode.position = SCNVector3(x, position.y, z)
                
                self.sceneLocationView.scene.rootNode.addChildNode(targetNode)
                
            }
        }
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {

        if let name = locationNode.name {
            
            switch name {
                
            case "start":
                
                draw(locationNode, inNodeType: .start)
                
            case "path":
                
                draw(locationNode, inNodeType: .path)
                
            case "end": print("end")
                
                draw(locationNode, inNodeType: .end)
                
            default: break
                
            }
        }
    }
}
