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

class ARViewController: UIViewController {

    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    let startNode = Node(nodeType: .start)
    var pathNodes: [Node] = []
    var isSaved: Bool = true
    var timer = Timer()
    var coordinatesPerMeter: [CLLocationCoordinate2D]?
    let mapViewController = MapViewController()
    
    //TODO: - Add Origin Point Setup and set it with sceneLocationView.currentScenePosition()
    //TODO: - Add new node automatically every 30 centermeter while user moving
    //TODO: - Add new node in the middle of view
    @IBAction func pathButton(_ sender: UIButton) {
        
        if isSaved == true {
            
            self.pathNodes = []
            
            //Add startNode at Origin Point
            
            startNode.position = SCNVector3(0,0,0)
            
            self.sceneLocationView.scene.rootNode.addChildNode(startNode)
            
            //Add pathNodes for current user location every 0.5 second
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            
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
        present(mapViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        self.sceneLocationView.session.run(configuration)
        
        self.sceneLocationView.autoenablesDefaultLighting = true
        
        mapViewController.delegate = self
        
        
    }
    
    private func upload() {
        
        // Upload new path to firebase
        let pathIdRef = FirebasePath.pathRef.childByAutoId()
        
        let startNodeRef = pathIdRef.child("start-node")
        
        let positionX = startNode.position.x, positionY = startNode.position.y, positionZ = startNode.position.z
        
        let sphereRadius = startNode.geometry!.boundingSphere.radius
        
        let values = [Position.Schema.x: positionX, Position.Schema.y: positionY, Position.Schema.z: positionZ, BoundingSphere.Schema.radius: sphereRadius]
        
        startNodeRef.setValue(values) { (error, ref) in
            
            if let error = error {
                
                print(error)
                
                return
            
            }
            
            for pathNode in self.pathNodes {
                
                // Upload new path to firebase
                let pathId = pathIdRef.key
                
                let pathNodesRef = FirebasePath.pathRef.child(pathId).child("path-nodes")
                
                let sphereRadius = pathNode.geometry!.boundingSphere.radius
                
                let values = [BoundingSphere.Schema.radius: sphereRadius]
                
                pathNodesRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                       
                        print(error)
                        
                        return
                    }
                    
                    let pointsPositionRef = pathNodesRef.child("position").childByAutoId()
                    
                    let positionX = pathNode.position.x, positionY = pathNode.position.y, positionZ = pathNode.position.z
                    
                    let values = [Position.Schema.x: positionX, Position.Schema.y: positionY, Position.Schema.z: positionZ]
                    
                    pointsPositionRef.updateChildValues(values)
                    
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
    
    @objc func timerAction() {
        
        let pathNode = Node(nodeType: .path)
        
        if let position = sceneLocationView.currentScenePosition() {
            
            pathNode.position = SCNVector3(position.x, position.y, position.z)
            
            self.startNode.addChildNode(pathNode)
            
            pathNodes.append(pathNode)
            
            print("Append OO\(self.pathNodes.count)")
        }
    }
}

extension ARViewController: CoordinateManagerDelegate {
    
    func didGet(coordinates: [CLLocationCoordinate2D]) {
        //do something
        // cash the coordinates
        self.coordinatesPerMeter = coordinates
        
//        startNode.position = SCNVector3(0,0,0)
        
        self.sceneLocationView.scene.rootNode.addChildNode(startNode)
        
    }
    
    
}

