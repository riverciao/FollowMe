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
    
//    private func adjustARAnchor() {
//
//
//        // Create anchor using the camera's current position
//        if let currentFrame = sceneLocationView.session.currentFrame {
//
//            // Create a transform with a translation of 30 cm in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.3
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            self.sceneLocationView.session.pause()
//            self.sceneLocationView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
//            sceneLocationView.session.add(anchor: anchor)
//        }
//
//    }
    
    private func fetchPath() {
        
        Database.database().reference().child("paths").observe( .childAdded) { (snapshot) in
            
            let pathId = snapshot.key
            let pathRef = Database.database().reference().child("paths").child(pathId)
            
            pathRef.observeSingleEvent(of: .value, with: { (pathSnapshot) in
                
                if let dictionary = pathSnapshot.value as? [String: AnyObject] {
                    
                    guard let startNode = dictionary["start-node"] as? [String: AnyObject] else { return }
                    
                    guard let latitude = startNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = startNode[NodeCoordinate.Schema.longitude] as? Double, let altitude = startNode[NodeCoordinate.Schema.altitude] as? Double else { return }
                    
//                    let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude)
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
                                
//                                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude)
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
    
    private func drawStartNode() {
        
        if let currentLocationCoordinate = currentLocationCoordinateForARSetting {
            let location = CLLocation(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
//            startNode = LocationAnnotationNode(location: location, image: UIImage(named: "pin")!)
            
            startNode = LocationSphereNode(location: location, nodeType: .start)
            
//            startNode.scaleRelativeToDistance = true
            if let startNode = startNode {
                
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: startNode)
                
            }
        }
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("123")
        
        drawStartNode()
        
        //the altitude must be position.z
//        if let position = sceneLocationView.currentScenePosition() {
//            print("This is the current location: X-\(position.x), Y-\(position.y), Z-\(position.z)")
//
//            newNode.position = SCNVector3(position.x, position.y, position.z)
//            self.node.addChildNode(newNode)
//        }
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
        
    }
}
