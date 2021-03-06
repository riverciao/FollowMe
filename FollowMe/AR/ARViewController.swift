//
//  ARViewController.swift
//  ARStarter
//
//  Created by riverciao on 2017/12/14.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import ARKit
import MapKit
import Firebase

protocol CoordinateManagerDelegate: class {
    
    func didGet(nodes: [HeadingNode])

}

class ARViewController: UIViewController, SceneLocationViewDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    
    let startNode = LocationAnnotationNode(location: nil, image: UIImage(named: "pin")!)
    var pathNodes: [LocationAnnotationNode] = []
    
    var isSaved: Bool = true
    var timer = Timer()
    var directionNodes: [HeadingNode]?
    let mapViewController = MapViewController()
    private var currentLocation: CLLocation?

    
    //TODO: - Add Origin Point Setup and set it with sceneLocationView.currentScenePosition()
    //TODO: - Add new node automatically every 30 centermeter while user moving
    //TODO: - Add new node in the middle of view
    @IBAction func pathButton(_ sender: UIButton) {
        
        if isSaved == true {
            
            //Clean pathNodes before adding a new path
            
            self.pathNodes = []

            //Add startNode at user current location

            startNode.scaleRelativeToDistance = true
            
            sceneLocationView.addLocationNodeForCurrentPosition(locationNode: startNode)
            
            //Add pathNodes for current user location per second
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addPathNodes), userInfo: nil, repeats: true)
            
            isSaved = false
            
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        
        restartSession()
    
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        upload()
        
        timer.invalidate()
        
        restartSession()
    
    }
    
    
    @IBAction func addNewPathByMapButton(_ sender: Any) {
        
        let mapViewController = MapViewController()
        let navigationController = UINavigationController(rootViewController: mapViewController)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        mapViewController.delegate = self
        
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
    
    
    
    private func upload() {
        
        // Upload new path to firebase
        let pathIdRef = FirebasePath.pathRef.childByAutoId()
        
        let startNodeRef = pathIdRef.child("start-node")
        
        let latitude = startNode.location.coordinate.latitude, longitude = startNode.location.coordinate.longitude, altitude = startNode.location.altitude

        
        // TODO: - change schema
        let values = [NodeCoordinate.Schema.latitude: latitude, NodeCoordinate.Schema.longitude: longitude, NodeCoordinate.Schema.altitude: altitude]
        
        startNodeRef.setValue(values) { (error, ref) in
            
            if let error = error {
                
                print(error)
                
                return
            
            }
            
            for pathNode in self.pathNodes {
                
                // Upload new path to firebase
                let pathId = pathIdRef.key
                
                let pathNodesRef = FirebasePath.pathRef.child(pathId).child("path-nodes")
                
                let pointsPositionRef = pathNodesRef.childByAutoId()
                
                let latitude = pathNode.location.coordinate.latitude, longitude = pathNode.location.coordinate.longitude, altitude = pathNode.location.altitude
                
                let values = [NodeCoordinate.Schema.latitude: latitude, NodeCoordinate.Schema.longitude: longitude, NodeCoordinate.Schema.altitude: altitude]
                
                pointsPositionRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                       
                        print(error)
                        
                        return
                    }
                
                })
           
            }
            
            self.isSaved = true
            
        }
    }

    
    private func restartSession() {
        
        self.sceneLocationView.session.pause()
        
        self.sceneLocationView.scene.rootNode.enumerateChildNodes { (node, _) in
            
            node.removeFromParentNode()
            
        }
        
        self.sceneLocationView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
    }
    
    @objc func addPathNodes() {
        
        let pathNodeImage = UIImage(named: "path-node")!
        
        let pathNode = LocationAnnotationNode(location: nil, image: pathNodeImage)
        
        pathNode.scaleRelativeToDistance = true
        
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: pathNode)
        
        pathNodes.append(pathNode)
        
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

extension ARViewController: CoordinateManagerDelegate {
    func didGet(nodes: [HeadingNode]) {
        
        self.directionNodes = nodes
        
        let node = nodes[0]
        let location = CLLocation(coordinate: node.coordinate, altitude: 0)
        let image = UIImage(named: "pin")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
    }
}

