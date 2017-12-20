//
//  MapViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/18.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark)
    func setRouteFromCurrentLocationCoordinate(destinationCoordinate: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    let locationSearchTableViewController = LocationSearchTableViewController()
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var route: MKRoute?
    var selectedPin: MKPlacemark? = nil
    
    // TODO: - delete this specific cordinate and make it optional
    var locationCoordinate = CLLocationCoordinate2DMake(25.025652, 121.556407)
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func goToARButton(_ sender: Any) {
        
//        let arViewController = ARViewController()
        
        
    }
    
    @IBAction func addPin(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        self.locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = Annotation(title: "", subtitle: "", coordinate: locationCoordinate)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        if let currentLocation = currentLocation {
            setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: locationCoordinate)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationSearchTableViewController.handleMapSearchDelegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //add addANewArticle navigationItem at rightside
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search(sender:)))
        
        //determines whether the Navigation Bar disappears when the search results are shown.
        //searchController?.hidesNavigationBarDuringPresentation = false
        
        //gives the modal overlay a semi-transparent background when the search bar is selected
        //searchController?.dimsBackgroundDuringPresentation = true
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func search(sender: UIBarButtonItem) {
        
        //Setup search results controller
        let searchController = UISearchController(searchResultsController: locationSearchTableViewController)
        
        searchController.searchResultsUpdater = locationSearchTableViewController
        searchController.searchBar.delegate = self
        
        // limits the overlap area to just the View Controller’s frame instead of the whole Navigation Controller
        definesPresentationContext = true
        
        //Pass Value
        locationSearchTableViewController.currentLocation = self.currentLocation
        locationSearchTableViewController.mapView = self.mapView
        present(searchController, animated: true, completion: nil)
        
    }
    
    private func setupAnnotationsFor(currentLocationCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        //TODO: - change the current location annotation pin to a blue point or something diffrent from destination
        let currentLocationAnnotation = Annotation(title: "Current Location", subtitle: "You are here now", coordinate: currentLocationCoordinate)
        let destinationAnnotation = Annotation(title: "Destination", subtitle: "You want to arrive here", coordinate: destinationCoordinate)
        
        self.mapView.showAnnotations([currentLocationAnnotation ,destinationAnnotation], animated: true )
    }
    
    private func getMapItem(with coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        return mapItem
    }

    
    func setRouteWith(currentLocationCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        // TODO: - not delete all the overlays but redraw a new path to replace the old one
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        setupAnnotationsFor(currentLocationCoordinate: currentLocationCoordinate, destinationCoordinate: destinationCoordinate)
        
        let currentLocationMapItem = getMapItem(with: currentLocationCoordinate)
        let destinationMapItem = getMapItem(with: destinationCoordinate)
        
        let directionRequest = MKDirectionsRequest()
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
            
            
            self.route = response.routes[0]
            
            // MARK: - Retrieve GPS coordinate from polyline
            
            let routeCoordinates = self.route?.polyline.coordinates
            let coordinatesPerMeter = self.getCoordinatesPerMeter(from: routeCoordinates!)
            
            print("OOOcoordinatesPerMeter\(coordinatesPerMeter.count)")
            print("OOOdistance\(String(describing: self.route?.distance))")
            
            var routeAnnotations: [Annotation] = []
            for routeCoordinate in coordinatesPerMeter {
                let routeAnnotation = Annotation(title: "routeAnnotation", subtitle: "", coordinate: routeCoordinate)
                routeAnnotations.append(routeAnnotation)
            }
            
            if let route = self.route {
                self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                for routeAnnotation in routeAnnotations {
                    self.mapView.addAnnotation(routeAnnotation)
                }
            }
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
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 600, 600)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignore user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            //Remove annotations
            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            
            //Getting data
            let latitude = response?.boundingRegion.center.latitude
            let longitude = response?.boundingRegion.center.longitude
            
            //Create annotation
            self.locationCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let annotation = Annotation(title: searchBar.text!, subtitle: "", coordinate: self.locationCoordinate)
            self.mapView.addAnnotation(annotation)
            
            //Draw the route
            if let currentLocation = self.currentLocation {
                self.setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: self.locationCoordinate)
            }
            
            //TODO: - adjust the scale of zoom in level (depends on the size of destination)
            //Zoom in on annotation
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(self.locationCoordinate, span)
            self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    typealias coordinates = [CLLocationCoordinate2D]
    
    public func getCoordinatesPerMeter(from coordinates: coordinates) -> coordinates {
        
        var coordinatesPerMeter = coordinates
        
        var segment: Int = 0
        
        for _ in 1..<coordinates.count {
            
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
                    
                    coordinatesPerMeter.append(newCoordinate)
                    
                    count += 1
                }
                
            }
            
            segment += 1
            
        }
        
        return coordinatesPerMeter
    }
    
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    // TODO: - write setRoute fonction only onece
    func setRouteFromCurrentLocationCoordinate(destinationCoordinate: CLLocationCoordinate2D) {
        
        // TODO: - not delete all the overlays but redraw a new path to replace the old one
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        if let currentLocation = self.currentLocation {
            setupAnnotationsFor(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: destinationCoordinate)
            
            let currentLocationMapItem = getMapItem(with: currentLocation.coordinate)
            let destinationMapItem = getMapItem(with: destinationCoordinate)
            
            let directionRequest = MKDirectionsRequest()
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
                
                
                self.route = response.routes[0]
                
                if let route = self.route {
                    self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                }
                
            }
        }
    }
}

