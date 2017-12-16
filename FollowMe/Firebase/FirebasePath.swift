//
//  FirebasePath.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/15.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import Foundation
import Firebase

public struct FirebasePath {
    
    public static let pathRef = Database.database().reference().child("paths")

}
