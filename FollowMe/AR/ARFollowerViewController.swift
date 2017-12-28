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

class ARFollowerViewController: UIViewController, SceneLocationViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var smallSyncMapView: MKMapView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    var startNode: LocationSphereNode?

    //currentlocation manager
    private var currentLocation: CLLocation?
    private var locationManager: CLLocationManager!
    var route: MKRoute?
    
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

        setupSmallSyncMapView()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.locationDelegate = self
        
        //add touch gesture
//        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
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
    
    private func getRouteInstructions() {
        let steps = self.route?.steps
        
        if let firstStep = steps?.first {
            self.instructionLabel.text = firstStep.instructions
            self.distanceLabel.text = "\(Int(firstStep.distance)) m"
        }
        
        
        
        for step in steps! {
            
            
            print("stepCoordinates\(step.polyline.coordinates) for \(step.instructions)")
            
            let coordinates = step.polyline.coordinates
            let instructions = step.instructions

            let coordinate = coordinates.last
            
            //Add the last coordinate of polyline to observe instruction
            let annotation = Annotation(title: "\(instructions)", subtitle: "", coordinate: coordinate!)
            self.smallSyncMapView.addAnnotation(annotation)
            
            if let currentLocation = self.currentLocation {

                
                let nextStepLocation = CLLocation(coordinate: coordinate!, altitude: 0)
                let distanceToShowNextStep = currentLocation.distance(from: nextStepLocation)
                
                print("distanceToShowNextStep\(distanceToShowNextStep)")
                
                if distanceToShowNextStep < 5 {
                    
                    self.instructionLabel.text = step.instructions
                    self.distanceLabel.text = "\(Int(step.distance)) m"


                }
                
            }
            
        }
    }
    
    private func setupSmallSyncMapView() {
        self.view.addSubview(smallSyncMapView)
        self.smallSyncMapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        // Check for Location Services
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func setupCurrentLocationAnnotation() {
        if let currentLocation = currentLocation {
            let annotation = Annotation(title: "", subtitle: "", coordinate: currentLocation.coordinate)
            self.smallSyncMapView.addAnnotation(annotation)
        }
    }
    
    @objc func handleTap(sender: UIGestureRecognizer) {
        
        let sceneViewTappedOn = sender.view as!  SceneLocationView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTestResults = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTestResults.isEmpty {
            
            hideDeletionCheckNode()
            
        } else {
            
            let node = hitTestResults.first?.node
            
            guard let nodeName = node?.name else { return }
            
            if nodeName == "delete" {
                
                if let pathNode = node?.parent as? Node {

                    showDeleteAlert(with: pathNode)
                    
                }
                
            } else  {
                
                guard let pathNode = hitTestResults.first?.node as? Node else { return }
                
                addDeletionCheckNode(fromParent: pathNode)
                
            }
        }
    }
    
    private func showDeleteAlert(with node: Node) {
        
        let alert = UIAlertController(
            title: NSLocalizedString("Are you sure to delete this route?", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        let delete = UIAlertAction(
            title: NSLocalizedString("Delete", comment: ""),
            style: .destructive,
            handler: { action in self.deletePath(from: node) }
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
    
    private func hideDeletionCheckNode() {
        
        self.sceneLocationView.scene.rootNode.enumerateChildNodes { (node, _) in
            
            if node.name == "delete" {
                
                node.removeFromParentNode()
                
            }
            
        }
        
    }
    
    private func deletePath(from selectedNode: Node) {
        
        if let pathId = selectedNode.belongToPathId {

            let pathRef = Database.database().reference().child("paths").child(pathId)

            pathRef.removeValue()

            removeNodes(with: pathId)

        }
        
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            
            
            currentLocation = locations.last
            setupCurrentLocationAnnotation()
            getRouteInstructions()
            
        }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                smallSyncMapView.centerCoordinate = userLocation.coordinate
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 150, 150)
                smallSyncMapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        smallSyncMapView.camera.heading = newHeading.magneticHeading
        smallSyncMapView.setCamera(smallSyncMapView.camera, animated: true)
        
    }
    
    private func addDeletionCheckNode(fromParent node: Node) {
        
        let deletionCheckNode = SCNNode()
        
        deletionCheckNode.geometry = SCNPlane(width: 0.8, height: 0.8)
        
        deletionCheckNode.name = "delete"
        
        //change to SCNCylinder
        
        deletionCheckNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "icon-delete")
        
        deletionCheckNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        deletionCheckNode.position = SCNVector3( 1.2, 1.2, 1.2)
        
        // plane node always face to user
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        deletionCheckNode.constraints = [billboardConstraint]
        
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
