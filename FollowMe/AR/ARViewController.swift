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
    
    func didGet(coordinates: [CLLocationCoordinate2D])

}

class ARViewController: UIViewController, SceneLocationViewDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    
    let startNode = LocationAnnotationNode(location: nil, image: UIImage(named: "pin")!)
    var pathNodes: [LocationAnnotationNode] = []
    
    var isSaved: Bool = true
    var timer = Timer()
    var coordinatesPerMeter: [CLLocationCoordinate2D]?
    let mapViewController = MapViewController()
    private var currentLocation: CLLocation?
    
    //Existed Path Property
    var existedStartNode: LocationAnnotationNode?
    var existedPathNode: LocationAnnotationNode?
    
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
            
            print("New Path to Be Saved")
            
        } else {
            
            print("wait for saving...")
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
        
        fetchPath()
        
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
                    
                    print("Saving OO\(self.pathNodes.count)")
                
                })
           
            }
            
            self.isSaved = true
            
            print("isSaved")
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

        print("Append OO\(self.pathNodes.count)")
        
    }
    
    private func fetchPath() {
        
        Database.database().reference().child("paths").observe( .childAdded) { (snapshot) in
            
            let pathId = snapshot.key
            let pathRef = Database.database().reference().child("paths").child(pathId)
            
            pathRef.observeSingleEvent(of: .value, with: { (pathSnapshot) in
                
                if let dictionary = pathSnapshot.value as? [String: AnyObject] {
                    
                    guard let startNode = dictionary["start-node"] as? [String: AnyObject] else { return }
                    
                    guard let latitude = startNode[NodeCoordinate.Schema.latitude] as? Double, let longitude = startNode[NodeCoordinate.Schema.longitude] as? Double, let altitude = startNode[NodeCoordinate.Schema.altitude] as? Double else { return }
                    
                    let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude)
                    
                    self.existedStartNode = LocationAnnotationNode(location: location, image: #imageLiteral(resourceName: "pin"))
                    
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.existedStartNode!)
                    
                    let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes")
                    
                    pathNodesRef.observe( .childAdded, with: { (pathNodesSnapshot) in
                        
                        let pathNodesId = pathNodesSnapshot.key
                        
                        let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes").child(pathNodesId)
                        
                        pathNodesRef.observeSingleEvent(of: .value, with: { (positionSnapshot) in
                            
                            if let dictionary = positionSnapshot.value as? [String: Any] {
                                
                                guard let latitude = dictionary[NodeCoordinate.Schema.latitude] as? Double, let longitude = dictionary[NodeCoordinate.Schema.longitude] as? Double, let altitude = dictionary[NodeCoordinate.Schema.altitude] as? Double else { return }
                                
                                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude)
                                
                                self.existedPathNode = LocationAnnotationNode(location: location, image: #imageLiteral(resourceName: "path-node"))
                                
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
        
    }
    
}

extension ARViewController: CoordinateManagerDelegate {
    
    func didGet(coordinates: [CLLocationCoordinate2D]) {
        //do something
        // cash the coordinates
        self.coordinatesPerMeter = coordinates
        
//        startNode.position = SCNVector3(0,0,0)
        let coordinate = coordinates[0]
        let location = CLLocation(coordinate: coordinate, altitude: 300)
        let image = UIImage(named: "pin")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        
        print("annotationNode\(annotationNode)")
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
//        self.sceneLocationView.scene.rootNode.addChildNode(startNode)
        
    }
    
    
}

