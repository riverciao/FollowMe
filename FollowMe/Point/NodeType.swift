//
//  NodeType.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/15.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import Foundation
import UIKit

public enum NodeType {
    
    // MARK: Case
    
    case start, path, end
    
}

// MARK: - Name

extension NodeType {
    
    var name: String {
        
        switch self {
            
        case .start:
            
            return "start"
            
        case .path:
            
            return "path"
            
        case .end:
            
            return "end"
            
        }
        
    }
    
}

// MARK: - Diffuse Content

extension NodeType {
    
    var diffuseContent: UIColor {
        
        switch self {
            
        case .start:
            
            return UIColor.green
            
        case .path:
            
            return UIColor.yellow
            
        case .end:
            
            return UIColor.red
            
        }
        
    }
    
}

// MARK: - Specular Contents

extension NodeType {
    
    var specularContent: UIColor {
        
        switch self {
            
        case .start:
            
            return UIColor.white
            
        case .path:
            
            return UIColor.white
            
        case .end:
            
            return UIColor.white
            
        }
        
    }
    
}

// MARK: - SCNSphere Radius

extension NodeType {
    
    var radius: CGFloat {
        
        switch self {
            
        case .start:
            
            return 1
            
        case .path:
            
            return 0.5
            
        case .end:
            
            return 1
            
        }
        
    }
    
}


