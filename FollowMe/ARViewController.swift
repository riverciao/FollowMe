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
    let node = Node(nodeType: .start)
    var timer = Timer()
    
    
    //TODO: - Add Origin Point Setup and set it with sceneLocationView.currentScenePosition()
    @IBAction func addButton(_ sender: Any) {
        
        node.position = SCNVector3(0,0,0)
        self.sceneLocationView.scene.rootNode.addChildNode(node)
        
        // Upload new path to firebase
        let startPointRef = FirebasePath.pathRef.child("start-point")
        
        let positionX = node.position.x, positionY = node.position.y, positionZ = node.position.z
        let sphereRadius = node.geometry!.boundingSphere.radius
        
        let values = [Position.Schema.x: positionX, Position.Schema.y: positionY, Position.Schema.z: positionZ, BoundingSphere.Schema.radius: sphereRadius]
        
        startPointRef.setValue(values)
        
    }

    
    //TODO: - Add new node automatically every 30 centermeter while user moving
    //TODO: - Add new node in the middle of view
    @IBAction func pathButton(_ sender: UIButton) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerAction() {
        
        let pathNode = Node(nodeType: .path)
        
        if let position = sceneLocationView.currentScenePosition() {

            pathNode.position = SCNVector3(position.x, position.y, position.z)
            self.node.addChildNode(pathNode)
            
            upload(pathNode)
            
        }
    }
    
    private func upload(_ pathNode: Node) {
        
        // Upload new path to firebase
        let pointsRef = FirebasePath.pathRef.child("points")
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


    
    @IBAction func resetButton(_ sender: Any) {
        restartSession()
    }
    
    private func restartSession() {
        self.sceneLocationView.session.pause()
        self.sceneLocationView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneLocationView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneLocationView.session.run(configuration)
        self.sceneLocationView.autoenablesDefaultLighting = true
    }


}

