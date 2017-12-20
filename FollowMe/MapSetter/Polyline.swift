//
//  Polyline.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/20.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import MapKit

public extension MKPolyline {
    
    public var coordinates: [CLLocationCoordinate2D] {
        
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        
        return coords
    }
}

public extension MKPolyline {
    
    typealias coordinates = [CLLocationCoordinate2D]
    
    public func getCoordinatesPerMeter(from coordinates: coordinates) -> coordinates {
        
        var coordinatesPerMeter = coordinates
        
        let segment: Int = 0
        
        // TODO: - add altitude to CLLocation argument
        
        let coordinate = coordinates[segment]
        
        let nextCoordinate = coordinates[segment + 1]
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let nextLocation = CLLocation(latitude: nextCoordinate.latitude, longitude: nextCoordinate.longitude)
        
        let distance = location.distance(from: nextLocation)
        
        var count: Double = 1
        
        if distance > 1 {
            
            for _ in 1..<Int(distance) {
                
                let  fraction = count/distance
                
                let startLatitude = coordinate.latitude
                
                let startLongitude = coordinate.longitude
                
                let endLatitude = nextCoordinate.latitude
                
                let endLongitude = nextCoordinate.longitude
                
                let newLatitude = startLatitude * fraction + endLatitude * (1 - fraction)
                
                let newLongitude = startLongitude * fraction + endLongitude * (1 - fraction)
                
                let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
                
                print("newCoordinateOOOO\(newCoordinate)")
                
                coordinatesPerMeter.append(newCoordinate)
                
                count += 1
            }
            
        }
        
        return coordinatesPerMeter
    }
}
