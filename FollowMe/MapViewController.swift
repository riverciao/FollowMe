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
    
    let locationCoordinate = CLLocationCoordinate2DMake(25.025652, 121.556407)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let distanceSpan: CLLocationDegrees = 250
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
    
    private func setupDestination() {
        
        // Setup destination
        let destinationLocation = CLLocationCoordinate2D(latitude: 25.025652, longitude: 121.556407)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "動桌遊"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
    }
    
    private func setupCurrentLocation() {
        // Setup current location
        let currentLocationAnnotation = MKPointAnnotation()
        currentLocationAnnotation.title = "Current Location"
        
        if let currentLocation = self.currentLocation {
            currentLocationAnnotation.coordinate = currentLocation.coordinate
            
            let currentLocationPlacemark = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
            let currentLocationMapItem = MKMapItem(placemark: currentLocationPlacemark)

        }
    }

    
    private func setRouteWith(currentLocationCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let directionRequest = MKDirectionsRequest()
        
        let currentLocationAnnotation = Annotation(title: "Current Location", subtitle: "You are here now", coordinate: currentLocationCoordinate)
        let destinationAnnotation = Annotation(title: "Destination", subtitle: "You want to arrive here", coordinate: destinationCoordinate)
        
        self.mapView.showAnnotations([currentLocationAnnotation ,destinationAnnotation], animated: true )
        
        let currentLocationPlacemark = MKPlacemark(coordinate: currentLocationCoordinate)
        let currentLocationMapItem = MKMapItem(placemark: currentLocationPlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        directionRequest.source = currentLocationMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
    
        
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
        defer {
            
            currentLocation = locations.last
            
            if let currentLocation = currentLocation {
                setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: locationCoordinate)
            }
        }
        
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
