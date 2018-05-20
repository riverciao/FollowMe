//
//  LocationSearchTableViewController.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/19.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit
import MapKit



class LocationSearchTableViewController: UITableViewController {

    let cellId = "CellID"
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    // TODO: - change to weak var delegate
    var handleMapSearchDelegate: HandleMapSearch? = nil
    var currentLocation: CLLocation?
    
    // MARK: - View life cycle
    
    deinit {
        print("location search view controller is dead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "LocationSearchTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "locationCell")
        
        // TODO: - change search bar in navigation bar
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
//        automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var locationCell = LocationSearchTableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? LocationSearchTableViewCell {
            
            let selectedItem = matchingItems[indexPath.row].placemark
            
            let selectedLocation = selectedItem.location
            
            cell.locationLabel.text = selectedItem.name
            
            cell.addressLabel.text = parseAddress(selectedItem: selectedItem)
            
            if let currentLocation = self.currentLocation {
                
                if let distance = selectedLocation?.distance(from: currentLocation) {
                    
                    cell.distanceLabel.text = "\(Int(distance)) m"

                } else {
                    
                    cell.distanceLabel.text = "? m"
                    
                }
                
            }
            
            
            locationCell = cell
        }
        
        return locationCell
    }
    
    
    
    //TODO: - rearrange address format
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }

}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            
            if let error = error {
                print("ERROR: \(error)")
                return
            }
            
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        handleMapSearchDelegate?.setRouteWith(currentLocationCoordinate: (currentLocation?.coordinate)!, destinationCoordinate: selectedItem.coordinate)
        
        dismiss(animated: true, completion: nil)
    }
    
}


