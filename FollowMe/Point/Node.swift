//
//  Node.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/16.
//  Copyright © 2017年 riverciao. All rights reserved.
//

// MARK: - Node

import ARKit
import SceneKit


class Node: SCNNode {
    
    // MARK: Property
    
    var nodeType: NodeType?
    
    var belongToPathId: String?
    
    // MARK: Init
    
    init(nodeType: NodeType, pathId: String) {
        
        super.init()
        
        self.nodeType = nodeType
        
        self.belongToPathId = pathId
        
        self.name = nodeType.name
        
        switch nodeType {
        case .start: self.geometry = SCNSphere(radius: nodeType.radius)
        case .end: self.geometry = SCNSphere(radius: nodeType.radius)
        case .path: self.geometry = SCNCone(topRadius: 1, bottomRadius: 0, height: 1)
        }
        
        self.geometry?.firstMaterial?.diffuse.contents = nodeType.diffuseContent
        
        self.geometry?.firstMaterial?.specular.contents = nodeType.specularContent
        

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
}
