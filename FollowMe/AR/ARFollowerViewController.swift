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

class ARFollowerViewController: UIViewController, SceneLocationViewDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
//    var startNode: LocationAnnotationNode?
    var startNode: LocationSphereNode?
    
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneLocationView.pause()
        
    }
    
    private func adjustARAnchor() {
        
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneLocationView.session.currentFrame {
            
            // Create a transform with a translation of 30 cm in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.3
            let transform = simd_mul(currentFrame.camera.transform, translation)

            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            self.sceneLocationView.session.pause()
            self.sceneLocationView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            sceneLocationView.session.add(anchor: anchor)
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
    
    private func findAnchor() {
        
        if let startNode = startNode {
            let what = sceneLocationView.anchor(for: startNode)
            print("OOOOO\(what)")
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("123")
        
//        adjustARAnchor()
        
        drawStartNode()
        
//        findAnchor()
        
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
