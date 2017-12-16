//
//  ARViewController.swift
//  ARStarter
//
//  Created by riverciao on 2017/12/14.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import ARKit
import Firebase

class ARViewController: UIViewController {

    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    let startNode = Node(nodeType: .start)
    var pathNodes: [Node] = []
    var timer = Timer()
    
    
    //TODO: - Add Origin Point Setup and set it with sceneLocationView.currentScenePosition()
    //TODO: - Add new node automatically every 30 centermeter while user moving
    //TODO: - Add new node in the middle of view
    @IBAction func pathButton(_ sender: UIButton) {
        
        //Add startNode at Origin Point
        startNode.position = SCNVector3(0,0,0)
        self.sceneLocationView.scene.rootNode.addChildNode(startNode)
        
        //Add pathNodes for current user location every 0.5 second
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func resetButton(_ sender: Any) {
        restartSession()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        upload(startNode: startNode)
        upload(pathNodes: pathNodes)
        
        // Clean after saving
        pathNodes = []
        restartSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneLocationView.session.run(configuration)
        self.sceneLocationView.autoenablesDefaultLighting = true
    }
    
    private func upload(startNode: Node) {
        
        // Upload new path to firebase
        let startPointRef = FirebasePath.pathRef.child("start-node")
        
        let positionX = startNode.position.x, positionY = startNode.position.y, positionZ = startNode.position.z
        let sphereRadius = startNode.geometry!.boundingSphere.radius
        
        let values = [Position.Schema.x: positionX, Position.Schema.y: positionY, Position.Schema.z: positionZ, BoundingSphere.Schema.radius: sphereRadius]
        
        startPointRef.setValue(values)

    }
    
    private func upload(pathNodes: [Node]) {
        
        for pathNode in pathNodes {
            
            // Upload new path to firebase
            let pointsRef = FirebasePath.pathRef.child("path-nodes")
            let sphereRadius = pathNode.geometry!.boundingSphere.radius
            
            let values = [BoundingSphere.Schema.radius: sphereRadius]
            
            pointsRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    print(error)
                    return
                }
                
                let pointsPositionRef = pointsRef.child("position").childByAutoId()
                
                let positionX = pathNode.position.x, positionY = pathNode.position.y, positionZ = pathNode.position.z
                let values = [Position.Schema.x: positionX, Position.Schema.y: positionY, Position.Schema.z: positionZ]
                
                pointsPositionRef.updateChildValues(values)
            })
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
            
        }
    }


}

