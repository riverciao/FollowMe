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
    
    // MARK: Init
    
    init(nodeType: NodeType) {
        
        super.init()
        
        self.nodeType = nodeType
        
        self.name = nodeType.name
        
        self.geometry = SCNSphere(radius: nodeType.radius)
        
        self.geometry?.firstMaterial?.diffuse.contents = nodeType.diffuseContent
        
        self.geometry?.firstMaterial?.specular.contents = nodeType.specularContent
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
}
