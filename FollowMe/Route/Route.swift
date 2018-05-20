//
//  Route.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/29.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import ARKit

struct RouteManager {
    
    //x, z for 3DVector converted from GPS
    var x: Float?
    var z: Float?
    
    public mutating func draw(_ locationPathNode: LocationPathNode, inNodeType nodeType: NodeType, atSceneLocationView sceneLocationView: SceneLocationView) {
        
        if !locationPathNode.isDrawn {
            
            if self.x != locationPathNode.position.x || self.z != locationPathNode.position.z {
                
                self.x = locationPathNode.position.x
                
                self.z = locationPathNode.position.z
                
                locationPathNode.isDrawn = true
                
                if let position = sceneLocationView.currentScenePosition(), let x = self.x, let z = self.z {
                    
                    let pathId = locationPathNode.belongToPathId
                    
                    let targetNode = Node(nodeType: nodeType, pathId: pathId)
                    
                    targetNode.position = SCNVector3(x, position.y, z)
                    
                    sceneLocationView.scene.rootNode.addChildNode(targetNode)
                    
                }
            }
        }
    }
    
    public mutating func drawStepBird(_ locationStepNode: LocationStepNode, atSceneLocationView sceneLocationView: SceneLocationView) throws {
        if !locationStepNode.isDrawn {
            
            locationStepNode.isDrawn = true
            
            //assign location node from GPS location to scsen node position
            self.x = locationStepNode.position.x
            self.z = locationStepNode.position.z
            
            let chickenScene = SCNScene(named: "art.scnassets/pintinho.scn")
            let chickenNode = chickenScene?.rootNode.childNode(withName: "Chicken", recursively: false)
            
            if let position = sceneLocationView.currentScenePosition(), let x = self.x, let z = self.z, let chickenNode = chickenNode {
                
                chickenNode.position = SCNVector3(x, position.y, z)
                sceneLocationView.scene.rootNode.addChildNode(chickenNode)
                
            } else {
                throw RouteError.chickenNodeNotFound
            }
            
        }
    }
    
    public mutating func drawArrow(_ locationPathNode: LocationPathNode, atSceneLocationView sceneLocationView: SceneLocationView) throws {
        
        if !locationPathNode.isDrawn {
            
            locationPathNode.isDrawn = true
            
            let arrowScene = SCNScene(named: "art.scnassets/arrow.scn")
            let triangleNode = arrowScene?.rootNode.childNode(withName: "Box1", recursively: false)
            let boxNode = arrowScene?.rootNode.childNode(withName: "Box", recursively: false)
            
            //assign location node from GPS location to scsen node position
            self.x = locationPathNode.position.x
            self.z = locationPathNode.position.z
            
            let arrowNode = SCNNode()
            if let triangleNode = triangleNode, let boxNode = boxNode {
                arrowNode.addChildNode(triangleNode)
                arrowNode.addChildNode(boxNode)
                arrowNode.scale = SCNVector3(2,2,2)
                
                if let position = sceneLocationView.currentScenePosition(), let x = self.x, let z = self.z {
                    
                    arrowNode.position = SCNVector3(x, position.y, z)
                    
                    //calculate angle of z and x
                    if let heading = locationPathNode.heading, let isMoreThan180Degree = locationPathNode.isMoreThan180Degree {
                        
                        switch isMoreThan180Degree {
                        case true: arrowNode.eulerAngles.y -= .pi + heading
                        case false: arrowNode.eulerAngles.y -= heading
                        }
                    }
                    
                    sceneLocationView.scene.rootNode.addChildNode(arrowNode)
                }
                
            } else {
                throw RouteError.arrowNodeNotFound
            }
        }
    }
}

enum RouteError: Error {
    case stepCoordinateNotFound
    case routeNotExist
    case currentPathIdNotExist
    case arrowNodeNotFound
    case chickenNodeNotFound
}
