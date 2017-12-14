//
//  ViewController.swift
//  ARStarter
//
//  Created by riverciao on 2017/12/14.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    let configuration = ARWorldTrackingConfiguration()
    let node = SCNNode()
    
    //TODO: - Add Origin Point Setup and set it with sceneLocationView.currentScenePosition()
    @IBAction func addButton(_ sender: Any) {
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)

        node.geometry?.firstMaterial?.specular.contents = UIColor.orange
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        node.position = SCNVector3(0,0,0)
        self.sceneLocationView.scene.rootNode.addChildNode(node)
        
    }

    //TODO: - Add new node automatically every 30 centermeter while user moving
    //TODO: - Add new node in the middle of view
    @IBAction func newNodeButton(_ sender: Any) {
        let newNode = SCNNode()


        newNode.geometry = SCNSphere(radius: 0.1)

        newNode.geometry?.firstMaterial?.specular.contents = UIColor.orange
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        
        if let position = sceneLocationView.currentScenePosition() {
            print("This is the current location: X-\(position.x), Y-\(position.y), Z-\(position.z)")
            
            newNode.position = SCNVector3(position.x, position.y, position.z)
//            self.node.addChildNode(newNode)
            self.sceneLocationView.scene.rootNode.addChildNode(newNode)
        }
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
    
    // random number from certain number to another number
//    private func randomNumbers(firstNum: CGFloat, SecondNum: CGFloat) -> CGFloat {
//        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - SecondNum) + min(firstNum, SecondNum)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneLocationView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneLocationView.session.run(configuration)
        self.sceneLocationView.autoenablesDefaultLighting = true
    }


}

