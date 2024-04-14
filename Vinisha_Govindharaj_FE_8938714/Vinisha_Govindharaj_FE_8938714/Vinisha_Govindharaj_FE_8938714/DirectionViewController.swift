//
//  DirectionViewController.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/8/24.
//

import UIKit
import MapKit
import CoreLocation
// ViewController handling the map view and routing functionalities
class DirectionViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Outlets for the map view on the UI
    
    @IBOutlet weak var mapView: MKMapView!
    // Location manager for handling locations
       let locationManager = CLLocationManager()
       
       // Annotations to mark the start and end of a route on the map
       var startAnnotation: MKPointAnnotation?
       var endAnnotation: MKPointAnnotation?
       
       // Setup initial view configurations when the view loads
       override func viewDidLoad() {
           super.viewDidLoad()
           
           // Location and map view settings
           locationManager.delegate = self
           locationManager.requestWhenInUseAuthorization()
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.startUpdatingLocation()
           mapView.delegate = self
           mapView.showsUserLocation = true
       }
       
       // Enum to manage different transport modes for the route directions
       enum TransportMode {
           case automobile
           case walking
           case transit // for public transport
           case cycling
       }
      
       // Button actions to calculate route based on transport mode
   
    @IBAction func carButtonPress(_ sender: Any) {
    
     showRoute(transportMode: .automobile)
    }
    
    @IBAction func bikeButtonPress(_ sender: Any) {
       showRoute(transportMode: .cycling)
    }
    
    @IBAction func walkButtonPress(_ sender: Any) {
    showRoute(transportMode: .walking)
    }
    
    @IBAction func busButtonPress(_ sender: Any) {
     showRoute(transportMode: .transit)
    }
    
    
    // Action to adjust the zoom level of the map
    
    @IBAction func zoomChange(_ sender: UISlider) {
        let spanValue = max(0.005, 0.05 - (CGFloat(sender.value) * 0.005))
           
           let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: spanValue, longitudeDelta: spanValue))
           mapView.setRegion(region, animated: true)
    }
    // Show dialog to input start and end locations
    @IBAction func changeLocationButton(_ sender: Any) {
        promptForLocations()
    }
    // Alert prompt for user to enter start and end locations
       func promptForLocations() {
           let alert = UIAlertController(title: "Where would you like to go?", message: "Enter your Destination", preferredStyle: .alert)
           alert.addTextField { textField in
               textField.placeholder = "Start location"
           }
           alert.addTextField { textField in
               textField.placeholder = "End location"
           }
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           alert.addAction(UIAlertAction(title: "Directions", style: .default) { [unowned self] _ in
               let startTextField = alert.textFields![0]
               let endTextField = alert.textFields![1]
               if let startLocationName = startTextField.text, !startLocationName.isEmpty,
                  let endLocationName = endTextField.text, !endLocationName.isEmpty {
                   self.geocodeAddress(startLocationName, isStartLocation: true)
                   self.geocodeAddress(endLocationName, isStartLocation: false)
               }
           })
           present(alert, animated: true)
       }

       // Geocodes an address string and adds it as an annotation on the map
       func geocodeAddress(_ address: String, isStartLocation: Bool) {
           CLGeocoder().geocodeAddressString(address) { [weak self] placemarks, error in
               guard let self = self, let placemark = placemarks?.first, let location = placemark.location else { return }
               DispatchQueue.main.async {
                   if isStartLocation {
                       self.addAnnotation(at: location.coordinate, title: "Start Location", isStart: true)
                   } else {
                       self.addAnnotation(at: location.coordinate, title: "End Location", isStart: false)
                   }
                   if let startAnnotation = self.startAnnotation, let endAnnotation = self.endAnnotation {
                       // Once both start and end locations are set, display the route
                       if startAnnotation.coordinate.latitude != 0, endAnnotation.coordinate.latitude != 0 {
                           self.showRoute(transportMode: .automobile) // Default to automobile for initial route display
                       }
                   }
               }
           }
       }

       // Add a point annotation to the map at a specified coordinate
       func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String, isStart: Bool) {
           let annotation = MKPointAnnotation()
           annotation.coordinate = coordinate
           annotation.title = title
           // Check if the annotation is marking the start or end of the route
           if isStart {
               if let existingAnnotation = startAnnotation {
                   mapView.removeAnnotation(existingAnnotation)
               }
               startAnnotation = annotation
           } else {
               if let existingAnnotation = endAnnotation {
                   mapView.removeAnnotation(existingAnnotation)
               }
               endAnnotation = annotation
           }
           mapView.addAnnotation(annotation)
       }

       // Calculate and show a route between two locations
       func showRoute(transportMode: TransportMode) {
           guard let startCoordinate = startAnnotation?.coordinate, let endCoordinate = endAnnotation?.coordinate else { return }
           let startPlacemark = MKPlacemark(coordinate: startCoordinate)
           let endPlacemark = MKPlacemark(coordinate: endCoordinate)
           
           let directionRequest = MKDirections.Request()
           directionRequest.source = MKMapItem(placemark: startPlacemark)
           directionRequest.destination = MKMapItem(placemark: endPlacemark)
           
           // Set the transportation type based on the selected mode
           switch transportMode {
           case .automobile:
               directionRequest.transportType = .automobile
           case .walking:
               directionRequest.transportType = .walking
           case .transit:
               directionRequest.transportType = .transit
           case .cycling:
               directionRequest.transportType = .walking // Note: MKDirections does not support cycling directly
           }
           
           let directions = MKDirections(request: directionRequest)
           directions.calculate { [weak self] (response, error) in
               guard let self = self, let route = response?.routes.first else { return }
               self.mapView.removeOverlays(self.mapView.overlays)
               self.mapView.addOverlay(route.polyline, level: .aboveRoads)
               let rect = route.polyline.boundingMapRect
               self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
           }
       }

       // Custom renderer for the route overlay. Specifies how the route should be visually represented on the map
       func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           if let polyline = overlay as? MKPolyline {
               let renderer = MKPolylineRenderer(polyline: polyline)
               renderer.strokeColor = UIColor.blue
               renderer.lineWidth = 5.0
               return renderer
           }
           return MKOverlayRenderer()
       }

       // Handle location updates
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let location = locations.first else { return }
           // Set an initial location if none is set
           if startAnnotation == nil {
               addAnnotation(at: location.coordinate, title: "Current Location", isStart: true)
               let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
               mapView.setRegion(region, animated: true)
           }
       }

       // Handle changes in location authorization
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if status == .authorizedWhenInUse || status == .authorizedAlways {
               locationManager.startUpdatingLocation()
           } else {
               // Alert or handle the case where location permissions are not granted
               print("Location permission not granted")
           }
       }
   }
