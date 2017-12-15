//
//  Point.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/15.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import Foundation
import ARKit

public struct Point {
    
    // MARK: Schema
    
    public struct Schema {
        
        public static let position = "position"
        
        public static let boundingSphere = "boundingSphere"
        
        
    }
    
    // MARK: Property
    
    public let position: Position
    
    public let boundingSphere: BoundingSphere
    
}

public struct Position {
    
    public struct Schema {
        
        public static let x = "x"
        
        public static let y = "y"
        
        public static let z = "z"
        
    }
    
    // MARK: Property
    
    public let x: Float
    
    public let y: Float
    
    public let z: Float
}

public struct BoundingSphere {
    
    public struct Schema {
        
        public static let radius = "radius"

    }
    
    // MARK: Property
    // retrive: newNode.geometry?.boundingSphere.radius
    public let radius: Float

}

