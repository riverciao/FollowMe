//
//  MapViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/18.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let distanceSpan: CLLocationDegrees = 250
        let locationCoordinate = CLLocationCoordinate2DMake(25.025652, 121.556407)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationCoordinate, distanceSpan, distanceSpan)

        mapView.setRegion(coordinateRegion, animated: true)
        
        let pinWithAnnotation = Annotation(title: "Dong", subtitle: "Play Game", coordinate: locationCoordinate)
        mapView.addAnnotation(pinWithAnnotation)
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setDestinationForRoute()
    }
    
    private func setDestinationForRoute() {
        
        let directionRequest = MKDirectionsRequest()
        
        let destinationLocation = CLLocationCoordinate2D(latitude: 25.025652, longitude: 121.556407)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "動桌遊"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        
        ///// fake start point
        let startLocation = CLLocationCoordinate2D(latitude: 25.027508, longitude: 121.555770)
        let startLocationPlacemark = MKPlacemark(coordinate: startLocation, addressDictionary: nil)
        let startLocationMapItem = MKMapItem(placemark: startLocationPlacemark)
        
        let startLocationAnnotation = MKPointAnnotation()
        startLocationAnnotation.title = "明月湯包"
        
        if let location = startLocationPlacemark.location {
            startLocationAnnotation.coordinate = location.coordinate
        }
        //////
        
//        let currentLocationAnnotation = MKPointAnnotation()
//        currentLocationAnnotation.title = "Current Location"
//
//        if let currentLocation = self.currentLocation {
//            currentLocationAnnotation.coordinate = currentLocation.coordinate
//
//            let currentLocationPlacemark = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
//            let currentLocationMapItem = MKMapItem(placemark: currentLocationPlacemark)
//
//            self.mapView.showAnnotations([currentLocationAnnotation ,destinationAnnotation], animated: true )
//
//
//            directionRequest.source = currentLocationMapItem
//            directionRequest.destination = destinationMapItem
//            directionRequest.transportType = .automobile
//        }
        
        //////
        self.mapView.showAnnotations([startLocationAnnotation ,destinationAnnotation], animated: true )
        
        
        directionRequest.source = startLocationMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        //////
        
        
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
           
            
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                
                return
                
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    // MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200)
                mapView.setRegion(viewRegion, animated: false)
                
                let pinWithAnnotation = Annotation(title: "Current Location", subtitle: "", coordinate: userLocation.coordinate)
                mapView.addAnnotation(pinWithAnnotation)
            }
        }
    }

}
