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
        
        public static let startNode = "start-node"
        
        public static let pathNodes = "path-nodes"
        
        
    }
    
    // MARK: Property
    
    public let startNode: NodeCoordinate
    
    public let pathNodes: NodeCoordinate
    
}

public struct NodeCoordinate {
    
    public struct Schema {
        
        public static let latitude = "latitude"
        
        public static let longitude = "longitude"
        
        public static let altitude = "altitude"
        
    }
    
    // MARK: Property
    
    public let latitude: Double
    
    public let longitude: Double
    
    public let altitude: Double
}

