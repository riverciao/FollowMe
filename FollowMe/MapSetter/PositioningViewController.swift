//
//  PositioningViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/23.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import MapKit

class PositioningViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    private var currentLocation: CLLocation?
    private var locationManager: CLLocationManager!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentLocationPointerImageView: UIImageView!
    
    @IBAction func confirmLocationButton(_ sender: Any) {
        
        let location = currentLocationPointerImageView.center
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        print("locationCoordinate\(locationCoordinate)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        setupCurrentLocationPointerImageView()
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    private func setupCurrentLocationPointerImageView() {
        
        //Rotate to point front side
        currentLocationPointerImageView.transform = currentLocationPointerImageView.transform.rotated(by: CGFloat.init(Double.pi * 3 / 2))
    }

    // MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            
            currentLocation = locations.last
            
        }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 60, 60)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
    }

}
