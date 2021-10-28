//
//  ChipMapViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import MapKit
import CoreLocation

class ChipMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var chipMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipMap.isZoomEnabled = true
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        checkLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set location to UT
        let initialLocation = CLLocation(latitude: 30.285607, longitude: -97.738202)
        chipMap.centerToLocation(initialLocation)
        chipMap.delegate = self
    }
    
    @IBAction func didTouchFilters(_ sender: Any) {
    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // need to enable zooming by changing these coords
//        if ((mapView.region.span.latitudeDelta > 30.291983 ) || (mapView.region.span.longitudeDelta > -97.742638) ) {
//            let centerCoord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(30.285607, -97.738202);
//            let UTRegion:MKCoordinateRegion = MKCoordinateRegion(center: centerCoord, latitudinalMeters: 700, longitudinalMeters: 700)
//            mapView.setRegion(UTRegion, animated: true);
//        }
//    }
    
    // MARK CURRENT USER LOCATION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 4000, longitudinalMeters: 4000)
            chipMap.setRegion(region, animated: true)
        }
       
        func checkLocationAuthorization() {
            switch locationManager.authorizationStatus {
            case .authorized:
                chipMap.showsUserLocation = true
                followUserLocation()
                locationManager.startUpdatingLocation()
                break
            case .denied:
                // Show alert
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                // Show alert
                break
            case .authorizedAlways:
                break
            default:
                fatalError()
            }
        }
        
        func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                // the user didn't turn it on
            }
        }
        
        func followUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 4000, longitudinalMeters: 4000)
                chipMap.setRegion(region, animated: true)
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
        
        func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
}
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000 //730
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
