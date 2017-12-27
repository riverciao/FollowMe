//
//  SmallSyncMapView.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/27.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import MapKit

class SmallSyncMapView: MKMapView {

    //, CLLocationManagerDelegate
//    private var currentLocation: CLLocation?
//    private var locationManager: CLLocationManager!
    
    @IBOutlet var smallSyncMapView: MKMapView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SmallSyncMapView", owner: self, options: nil)
        addSubview(smallSyncMapView)
        smallSyncMapView.frame = self.bounds
        smallSyncMapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        
//        
//        // Check for Location Services
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
        
    }
    
//    private func setupCurrentLocationAnnotation() {
//        if let currentLocation = currentLocation {
//            let annotation = Annotation(title: "", subtitle: "", coordinate: currentLocation.coordinate)
//            self.smallSyncMapView.addAnnotation(annotation)
//        }
//    }
    
//    // MARK - CLLocationManagerDelegate
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        defer {
//            
//            currentLocation = locations.last
//            
//        }
//        
//        if currentLocation == nil {
//            // Zoom to user location
//            if let userLocation = locations.last {
//                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 100, 100)
//                smallSyncMapView.setRegion(viewRegion, animated: false)
//            }
//        }
//    }

}