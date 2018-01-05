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
    private var locationManager = CLLocationManager()
    let queue = OperationQueue()
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var headerContent: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentLocationPointerImageView: UIImageView!
    
    @IBOutlet weak var confirmButtton: UIButton!
    
    @IBAction func confirmLocationButton(_ sender: Any) {
        
        let location = currentLocationPointerImageView.center
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        //Transfer to mapViewController
        let mapViewController = MapViewController()
        
        mapViewController.currentLocationCoordinateForARSetting = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        self.navigationController?.pushViewController(mapViewController, animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingHeading()

        setupCurrentLocationPointerImageView()
        setupHeader()
        setupConfirmButton()
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    private func setupCurrentLocationPointerImageView() {
        
        //Rotate to point front side
        currentLocationPointerImageView.transform = currentLocationPointerImageView.transform.rotated(by: CGFloat.init(Double.pi * 3 / 2))
        
    }
    
    
    func setupHeader() {
        
        headerView.backgroundColor = Palette.seaBlue
        
        headerTitle.textColor = .white
        
        headerContent.textColor = .white
        
        headerTitle.font = UIFont(name: "ChalkboardSE-Regular", size: 24)
        
        headerContent.font = UIFont.systemFont(ofSize: 18)

    }
    
    
    func setupConfirmButton() {
        
        confirmButtton.setTitleColor(.white, for: .normal)
        
        confirmButtton.backgroundColor = Palette.duckBeak
        
        confirmButtton.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 32)
        
        confirmButtton.layer.cornerRadius = 12
    }


    // MARK: - CLLocationManagerDelegate
    // TODO: - track location and heading for onece and do not keep  tracking to let user adjust it by self
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        mapView.camera.heading = newHeading.magneticHeading
        mapView.setCamera(mapView.camera, animated: true)
    
    }

}
