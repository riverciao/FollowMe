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
    var existedStartNode: LocationPathNode?
    var existedPathNode: LocationPathNode?
    var existedPathNodes: [LocationPathNode] = []
    var existedEndNode: LocationPathNode?
    
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
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneLocationView.addGestureRecognizer(longPressGestureRecognizer)

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
        let hitTestResults = sceneViewTappedOn.hitTest(touchCoordinates)
        
        guard let node = hitTestResults.first?.node as? Node else { return }
        
        addDeletionCheckNode(with: node)
        
//        if let pathId = node.belongToPathId {
//
//            let pathRef = Database.database().reference().child("paths").child(pathId)
//
//            pathRef.removeValue()
//
//            removeNodes(with: pathId)
//
//
//        }
        
    }
    
    private func addDeletionCheckNode(with node: Node) {
        
        let deletionCheckNode = SCNNode()
        
        deletionCheckNode.geometry = SCNPlane(width: 10, height: 10)
        
        deletionCheckNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "button_close")
        
        //            plane.geometry?.firstMaterial?.specular.contents
        
        deletionCheckNode.position = SCNVector3(1.5,1.5,1.5)
        
        node.addChildNode(deletionCheckNode)
    }
    
    private func removeNodes(with pathId: pathId) {
        
        self.sceneLocationView.scene.rootNode.enumerateChildNodes { (node, _) in
            
            if let pathNode = node as? Node {
                
                if pathNode.belongToPathId == pathId {
                    
                    pathNode.removeFromParentNode()
                }
            }
        }
    }
    
    private func retrieveStartNode(from dictionary: [String: AnyObject], with pathId: pathId) {
        
        //retrieve start node
        guard let startNode = dictionary["start-node"] as? [String: AnyObject] else { return }
        
        guard let latitude = startNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = startNode[NodeCoordinate.Schema.longitude] as? Double, let altitude = startNode[NodeCoordinate.Schema.altitude] as? Double else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.existedStartNode = LocationPathNode(location: location, belongToPathId: pathId)
        
        self.existedStartNode?.name = "start"
        
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedStartNode!)
        
        self.existedStartNode?.removeFromParentNode()
    }
    
    private func retrieveEndNode(from dictionary: [String: AnyObject], with pathId: pathId) {
        
        //retrieve start node
        guard let endNode = dictionary["end-node"] as? [String: AnyObject] else { return }
        
        guard let latitude = endNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = endNode[NodeCoordinate.Schema.longitude] as? Double else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.existedEndNode = LocationPathNode(location: location, belongToPathId: pathId)
        
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
                    
                    self.existedPathNode = LocationPathNode(location: location, belongToPathId: pathId)
                    
                    self.existedPathNode?.name = "path"
                    
                    self.existedPathNodes.append(self.existedPathNode!)
                    
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
                    
                    self.retrieveStartNode(from: dictionary, with: pathId)
                    
                    self.retrieveEndNode(from: dictionary, with: pathId)
                    
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
    
    private func draw(_ locationPathNode: LocationPathNode, inNodeType nodeType: NodeType) {
        
        if !locationPathNode.isDrawn {
            
            if self.x != locationPathNode.position.x || self.z != locationPathNode.position.z {
                
                self.x = locationPathNode.position.x
                
                self.z = locationPathNode.position.z
                
                locationPathNode.isDrawn = true
                
                if let position = sceneLocationView.currentScenePosition(), let x = self.x, let z = self.z {
                    
                    let pathId = locationPathNode.belongToPathId
                    
                    let targetNode = Node(nodeType: nodeType, pathId: pathId)
                    
                    targetNode.position = SCNVector3(x, position.y, z)
                    
                    self.sceneLocationView.scene.rootNode.addChildNode(targetNode)
                    
                }
            }
        }
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
        if let name = locationNode.name {
            
            switch name {
                
            case "start":
                
                if let locationPathNode = locationNode as? LocationPathNode {

                    draw(locationPathNode, inNodeType: .start)

                }
                
            case "path":
                
                if let locationPathNode = locationNode as? LocationPathNode {

                    draw(locationPathNode, inNodeType: .path)

                }
                
            case "end":
                
                if let locationPathNode = locationNode as? LocationPathNode {
                    
                    draw(locationPathNode, inNodeType: .end)
                    
                }
                
            default: break
                
            }
        }
    }
}
