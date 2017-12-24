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
    var coordinatesPerMeter: [CLLocationCoordinate2D] = []
    // TODO: - weak var delegate
    var delegate: CoordinateManagerDelegate? = nil
    
    var isSaved: Bool = true
    
    var destinationCoordinate: CLLocationCoordinate2D?
    
    var currentLocationCoordinateForARSetting: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func goToARButton(_ sender: Any) {
        
        upload()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func CancelButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPin(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        self.destinationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        if let destinationCoordinate = destinationCoordinate, let currentLocation = currentLocation {
            let annotation = Annotation(title: "", subtitle: "", coordinate: destinationCoordinate)
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(annotation)
            
            setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: destinationCoordinate)
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
    
    private func setupAnnotationsFor(destinationCoordinate: CLLocationCoordinate2D) {
        
        let destinationAnnotation = Annotation(title: "Destination", subtitle: "You want to arrive here", coordinate: destinationCoordinate)
        
        self.mapView.addAnnotation(destinationAnnotation)
    }
    
    private func setupAnnotationsFor(currentLocationCoordinate: CLLocationCoordinate2D) {
        
        //TODO: - change the current location annotation pin to a blue point or something diffrent from destination
        
        let currentLocationAnnotation = Annotation(title: "Current Location", subtitle: "You are here now", coordinate: currentLocationCoordinate)
        
        self.mapView.showAnnotations([currentLocationAnnotation], animated: true)
        
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
        
        setupAnnotationsFor(destinationCoordinate: destinationCoordinate)
        
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
            self.coordinatesPerMeter = self.getCoordinatesPerMeter(from: routeCoordinates!)
            
            //Pass Value back to ARViewController
            DispatchQueue.main.async {
                self.delegate?.didGet(coordinates: self.coordinatesPerMeter)
            }
            
            if let route = self.route {
                
                self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)

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
            
            //Setup current location annotation
            if let currentLocation = self.currentLocation {
                
                setupAnnotationsFor(currentLocationCoordinate: currentLocation.coordinate)
                
            }
            
            if let currentLocation = currentLocation, let destinationCoordinate = destinationCoordinate {
                
                setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: destinationCoordinate)
                
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
            self.destinationCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let annotation = Annotation(title: searchBar.text!, subtitle: "", coordinate: self.destinationCoordinate!)
            self.mapView.addAnnotation(annotation)
            
            //Draw the route
            if let currentLocation = self.currentLocation {
                self.setRouteWith(currentLocationCoordinate: currentLocation.coordinate, destinationCoordinate: self.destinationCoordinate!)
            }
            
            //TODO: - adjust the scale of zoom in level (depends on the size of destination)
            //Zoom in on annotation
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(self.destinationCoordinate!, span)
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
    
    //TODO: - make component
    //MARK: - upload to firebase
    
    private func upload() {
        
        // Upload new path to firebase
        let pathIdRef = FirebasePath.pathRef.childByAutoId()
        
        let startNodeRef = pathIdRef.child("start-node")
        
        //Make current location assign only onece when user press add path button
        
        guard let currentLocation = currentLocation else {
         
            print("currentLocation not found")
            
            return
            
        }
            
        let latitude = currentLocation.coordinate.latitude, longitude = currentLocation.coordinate.longitude, altitude = 29
        
        // TODO: - change schema
        let values = [NodeCoordinate.Schema.latitude: latitude, NodeCoordinate.Schema.longitude: longitude, NodeCoordinate.Schema.altitude: altitude] as [String : Any]
        
        startNodeRef.setValue(values) { (error, ref) in
            
            if let error = error {
                
                print(error)
                
                return
                
            }
            
            for pathNode in self.coordinatesPerMeter {
                
                // Upload new path to firebase
                let pathId = pathIdRef.key
                
                let pathNodesRef = FirebasePath.pathRef.child(pathId).child("path-nodes")
                
                let pointsPositionRef = pathNodesRef.childByAutoId()
                
                let latitude = pathNode.latitude, longitude = pathNode.longitude, altitude = 29
                
                let values = [NodeCoordinate.Schema.latitude: latitude, NodeCoordinate.Schema.longitude: longitude, NodeCoordinate.Schema.altitude: altitude] as [String : Any]
                
                pointsPositionRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        
                        print(error)
                        
                        return
                    }
                    
                    print("Saving OO\(self.coordinatesPerMeter.count)")
                    
                })
                
            }
            
            self.isSaved = true
            
            print("isSaved")
        }
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
            setupAnnotationsFor(destinationCoordinate: destinationCoordinate)
            
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

