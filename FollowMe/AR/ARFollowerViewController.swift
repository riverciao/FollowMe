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

typealias pathId = String

class ARFollowerViewController: UIViewController, SceneLocationViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var smallSyncMapView: MKMapView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()
    var startNode: LocationSphereNode?
    
    //currentlocation manager
    private var currentLocation: CLLocation?
    private var locationManager: CLLocationManager!
    var currentLocationAnnotation: Annotation?
    var route: MKRoute?

    //Existed Path Property
    var existedStartNode: LocationPathNode?
    var existedPathNode: LocationPathNode?
    var existedPathNodes: [LocationPathNode] = []
    var existedEndNode: LocationPathNode?
    
    //take pathId from mapViewController
    var currentPathId: pathId?
    
    //Route screen shot
    var routeImageView: UIImageView?
    
    //take instructions from location node -> step node
    var locationStepNodes: [LocationStepNode] = [] {
        didSet {
                
            guard let firstStepNode = locationStepNodes.first else { return }
            self.instructionLabel.text = firstStepNode.instruction
            self.distanceLabel.text = "\(firstStepNode.distance) m"
            
            for locationStepNode in locationStepNodes {
                
                if let currentLocation = self.currentLocation {
                    
                    let nextStepLocation = CLLocation(coordinate: locationStepNode.location.coordinate, altitude: 0)
                    let distanceToShowNextStep = currentLocation.distance(from: nextStepLocation)
                    
                    if distanceToShowNextStep < 5 {
                        
                        self.instructionLabel.text = locationStepNode.instruction
                        self.distanceLabel.text = "\(locationStepNode.distance) m"
                        
                    }
                }
            }
        }
    }
    
    //x, z for 3DVector converted from GPS
    var x: Float?
    var z: Float?
    
    //property for current location coordinate to start node 3D vector
    var currentLocationCoordinateForARSetting: CLLocationCoordinate2D?
    
    //notice for user to look around
    var noticeViewAlpha: CGFloat = 0.5
    lazy var noticeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: noticeViewAlpha)
        return view
    }()
    
    //caution for user to be aware of surroundings
    lazy var cautionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: noticeViewAlpha)
        return view
    }()
    
    //timer for notice view to fade out
    var fadeOutTimer = Timer()
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSmallSyncMapView()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.locationDelegate = self
        
        smallSyncMapView.showsCompass = false
        
        //add touch gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneLocationView.addGestureRecognizer(tapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneLocationView.run()
        
        fetchPath()

        getRouteInstructions()
        
        self.navigationController?.navigationBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneLocationView.pause()
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupStatusBarColor()
        setupHeader()
        setupNoticeViewAndCautionView()
        setupTimer()
        
    }
    
    // MARK: - get instruction
    
    private func getRouteInstructions() {
        
        guard let steps = self.route?.steps else {
            
            retrieveStepNodes(with: currentPathId!)
            
            return
            
        }
        
        if let firstStep = steps.first {
            self.instructionLabel.text = firstStep.instructions
            self.distanceLabel.text = "\(Int(firstStep.distance)) m"
        }
        
        for step in steps {
            
            let coordinates = step.polyline.coordinates
            let instructions = step.instructions

            let coordinate = coordinates.last
            
            //Add the last coordinate of polyline to observe instruction
            let annotation = Annotation(title: "\(instructions)", subtitle: "", coordinate: coordinate!)
            self.smallSyncMapView.addAnnotation(annotation)
            
            if let currentLocation = self.currentLocation {
                
                let nextStepLocation = CLLocation(coordinate: coordinate!, altitude: 0)
                let distanceToShowNextStep = currentLocation.distance(from: nextStepLocation)
                
                if distanceToShowNextStep < 5 {
                    
                    self.instructionLabel.text = step.instructions
                    self.distanceLabel.text = "\(Int(step.distance)) m"


                }
                
            }
            
        }
    }
    
    // MARK: - Setup
    
    @objc private func setupNoticeViewAndCautionView() {
        
        //TODO: dynamic height for view
        view.addSubview(noticeView)
        
        noticeView.layer.cornerRadius = view.frame.height * 1/40
        noticeView.clipsToBounds = true
        
        noticeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noticeView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 1/3).isActive = true
        noticeView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        noticeView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let noticeLabel = UILabel()
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        noticeLabel.text = "Look around to find the route instructions in AR."
        noticeLabel.font = UIFont.systemFont(ofSize: 18)
        noticeLabel.textColor = .white
        noticeLabel.numberOfLines = 0
        
        noticeView.addSubview(noticeLabel)
        
        noticeLabel.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor).isActive = true
        noticeLabel.centerYAnchor.constraint(equalTo: noticeView.centerYAnchor).isActive = true
        noticeLabel.widthAnchor.constraint(equalToConstant: noticeView.frame.width * 0.9).isActive = true
        noticeLabel.heightAnchor.constraint(equalToConstant: noticeView.frame.height * 0.9).isActive = true
        
        view.addSubview(cautionView)
        
        cautionView.layer.cornerRadius = view.frame.height * 1/40
        cautionView.clipsToBounds = true
        
        cautionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cautionView.topAnchor.constraint(equalTo: noticeView.bottomAnchor, constant: 10).isActive = true
        cautionView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        cautionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let cautionLabel = UILabel()
        cautionLabel.translatesAutoresizingMaskIntoConstraints = false
        cautionLabel.text = "Please be aware of your surroundings."
        cautionLabel.font = UIFont.systemFont(ofSize: 18)
        cautionLabel.textColor = .white
        cautionLabel.numberOfLines = 0
        
        cautionView.addSubview(cautionLabel)
        
        cautionLabel.centerXAnchor.constraint(equalTo: cautionView.centerXAnchor).isActive = true
        cautionLabel.centerYAnchor.constraint(equalTo: cautionView.centerYAnchor).isActive = true
        cautionLabel.widthAnchor.constraint(equalToConstant: cautionView.frame.width * 0.9).isActive = true
        cautionLabel.heightAnchor.constraint(equalToConstant: cautionView.frame.height * 0.9).isActive = true
    }
    
    //timer for notice and caution view
    private func setupTimer() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideNoticeView), userInfo: nil, repeats: false)
    }
    
    @objc private func hideNoticeView() {
        fadeOutTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fadeOut), userInfo: nil, repeats: true)
    }
    
    @objc private func fadeOut() {
        
        if noticeViewAlpha > 0 {
            noticeViewAlpha -= 0.1
            noticeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: noticeViewAlpha)
            cautionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: noticeViewAlpha)
        } else if noticeViewAlpha <= 0 {
            noticeView.isHidden = true
            cautionView.isHidden = true
            fadeOutTimer.invalidate()
        }
    }
    
    private func setupHeader() {
        
        headerView.backgroundColor = Palette.seaBlue
        instructionLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 24)
        instructionLabel.textColor = .white
        distanceLabel.textColor = .white
        
        //setup cancel button
        let cancelImage = #imageLiteral(resourceName: "icon-cross").withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(cancelImage, for: .normal)
        cancelButton.tintColor = .white
        
        //if draw route by self, showSaveAlert, otherwise cancel
        if self.navigationController?.viewControllers[1] != nil {
            cancelButton.addTarget(self, action: #selector(showSaveAlert), for: .touchUpInside)
        } else {
            cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        }
        
    }
    
    @objc private func showSaveAlert() {
        
        let alert = UIAlertController(
            title: NSLocalizedString("Do you want to save this route?", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .default,
            handler: { action in self.delete() }
        )
        
        let save = UIAlertAction(
            title: NSLocalizedString("Save", comment: ""),
            style: .default,
            handler: { action in self.cancel() }
        )
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func delete() {
        if let currentPathId = currentPathId {
            
            //delete from firebase
            let pathRef = Database.database().reference().child("paths").child(currentPathId)
            pathRef.removeValue()
            
            //delete from coredata
            guard let fetchResults = CoreDataHandler.filterData(selectedItemId: currentPathId) else {
                print("route not exist")
                return
            }
            
            let resultToBeDeleted = fetchResults[0]
            CoreDataHandler.deleteObject(item: resultToBeDeleted)
        } else {
            print("currentPathId not exist")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
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
    
    func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = Palette.seaBlue
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupCurrentLocationAnnotation() {
        if let currentLocation = currentLocation {

            self.currentLocationAnnotation = Annotation(title: "", subtitle: "", coordinate: currentLocation.coordinate)
            self.smallSyncMapView.addAnnotation(self.currentLocationAnnotation!)
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
    
    private func retrieveStepNodes(with pathId: pathId) {
        
        let stepNodesRef = Database.database().reference().child("paths").child(pathId).child("step-nodes")
        
        stepNodesRef.observe( .childAdded, with: { [weak self] (stepNodesSnapshot) in
            
            let stepNodeId = stepNodesSnapshot.key
            
            let stepNodeRef = Database.database().reference().child("paths").child(pathId).child("step-nodes").child(stepNodeId)
            
            stepNodeRef.observeSingleEvent(of: .value, with: { (snapShot) in
                
                if let dictionary = snapShot.value as? [String: Any] {
                    
                    guard let latitude = dictionary["latitude"] as? Double, let longitude = dictionary["longitude"] as? Double, let instruction = dictionary["instruction"] as? String, let distance = dictionary["distance"] as? Int else { return }
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    let locationStepNode = LocationStepNode(location: location, instruction: instruction, for: distance)

                    self?.locationStepNodes.append(locationStepNode)
 
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            
            
            currentLocation = locations.last
            setupCurrentLocationAnnotation()
            
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
    
    
    private func retrievePathNodes(with pathId: pathId) {
        
        let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes")
        
        pathNodesRef.observe( .childAdded, with: { [weak self] (pathNodesSnapshot) in
            
            let pathNodesId = pathNodesSnapshot.key
            
            let pathNodesRef = Database.database().reference().child("paths").child(pathId).child("path-nodes").child(pathNodesId)
            
            pathNodesRef.observeSingleEvent(of: .value, with: { (positionSnapshot) in
                
                if let dictionary = positionSnapshot.value as? [String: Any] {
                    
                    guard let latitude = dictionary[NodeCoordinate.Schema.latitude] as? Double, let longitude = dictionary[NodeCoordinate.Schema.longitude] as? Double, let altitude = dictionary[NodeCoordinate.Schema.altitude] as? Double else { return }
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    self?.existedPathNode = LocationPathNode(location: location, belongToPathId: pathId)
                    
                    self?.existedPathNode?.name = "path"
                    
                    if let existedPathNode = self?.existedPathNode {
                        
                        self?.existedPathNodes.append(existedPathNode)
                        
                        self?.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: existedPathNode)
                    }
                    
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }

    
    private func fetchPath() {
        
        Database.database().reference().child("paths").observe( .childAdded) { [weak self] (snapshot) in
            
//            let pathId = snapshot.key
            
            guard let pathId = self?.currentPathId else {
                
                // TODO: - if not receive currentPathId form mapViewController
                return
            }
            
            // TODO: - invalid pathId
            
            let pathRef = Database.database().reference().child("paths").child(pathId)
            
            pathRef.observeSingleEvent(of: .value, with: { (pathSnapshot) in
                
                if let dictionary = pathSnapshot.value as? [String: AnyObject] {
                    
                    self?.retrieveStartNode(from: dictionary, with: pathId)
                    
                    self?.retrieveEndNode(from: dictionary, with: pathId)
                    
                    self?.retrievePathNodes(with: pathId)

                }
                
            }, withCancel: nil)
            
        }
        
    }
    
    private func setupAnnotationsFor(destinationCoordinate: CLLocationCoordinate2D) {
        
        let destinationAnnotation = Annotation(title: "Destination", subtitle: "You want to arrive here", coordinate: destinationCoordinate)
        
        self.smallSyncMapView.addAnnotation(destinationAnnotation)
    }
    
    private func setupAnnotationsFor(currentLocationCoordinate: CLLocationCoordinate2D) {
        
        //TODO: - change the current location annotation pin to a blue point or something diffrent from destination
        
        let currentLocationAnnotation = Annotation(title: "Current Location", subtitle: "You are here now", coordinate: currentLocationCoordinate)
        
        self.smallSyncMapView.showAnnotations([currentLocationAnnotation], animated: true)
        
    }
    
    private func getMapItem(with coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        return mapItem
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
