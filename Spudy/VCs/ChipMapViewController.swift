//
//  ChipMapViewController.swift
//  Spudy
//
//  Created by Shamira Kabir on 10/12/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

protocol MapFilterSetter {
    func setClasses (classesFilter: [String])
    func setFilterMode (filter: String)
}

class ChipMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MapFilterSetter {

    let locationManager = CLLocationManager()
    var profileRef: DatabaseReference!
    var classRef: DatabaseReference!
    
    var filters: String!
    var friends: [String]!
    var classmates: [String]!
    var classesFilter: [String] = []
    
    @IBOutlet weak var chipMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipMap.isZoomEnabled = true
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        classRef = Database.database().reference(withPath: Constants.DatabaseKeys.classPath)

        getFriends()
        setupLocationManager()
        checkLocationServices()
        showPeople()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set location to UT
        let initialLocation = CLLocation(latitude: 30.285607, longitude: -97.738202)
        chipMap.centerToLocation(initialLocation)
        chipMap.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.Segues.filterSegueIdentifier) {
            let destination = segue.destination as! ChipMapFiltersViewController
            destination.mapFilterDelegate = self
        }
    }
    
    func getFriends() {
        profileRef.observe(.value) { snapshot in
            let profiles = snapshot.value as? NSDictionary
            let user = profiles?[CURRENT_USER] as? NSDictionary
            self.friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []

        }
    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // need to enable zooming by changing these coords
//        if ((mapView.region.span.latitudeDelta > 30.291983 ) || (mapView.region.span.longitudeDelta > -97.742638) ) {
//            let centerCoord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(30.285607, -97.738202);
//            let UTRegion:MKCoordinateRegion = MKCoordinateRegion(center: centerCoord, latitudinalMeters: 700, longitudinalMeters: 700)
//            mapView.setRegion(UTRegion, animated: true);
//        }
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let location = view.annotation?.coordinate
//        let region = MKCoordinateRegion.init(center: location!, latitudinalMeters: 200, longitudinalMeters: 200)
//        chipMap.setRegion(region, animated: true)
//        let username = view.annotation?.subtitle
//        performSegue(withIdentifier: Constants., sender: <#T##Any?#>)
    }
    
    // MARK CURRENT USER LOCATION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let userLatitude = location.coordinate.latitude
        let userLongitude = location.coordinate.longitude
        
        saveUserLocationToFirebase(longitude: userLongitude, latitude: userLatitude)
    }
   
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorized:
            chipMap.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // TODO Show alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO Show alert
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func setupLocationManager() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    // MARK Map Annotations
    
    func setUserAnnotation(username: String, person: NSDictionary?) {
        let lat = person?[Constants.DatabaseKeys.latitude] as? Double ?? nil
        let long = person?[Constants.DatabaseKeys.longitude] as? Double ?? nil
        // add person to map
        if (lat != nil && long != nil) {
            let name = person?[Constants.DatabaseKeys.name] as! String
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            let photoURLString = person?[Constants.DatabaseKeys.photo] as? String
            let annotation = UserMKAnnotation(name: name, username: username, coord: coordinate, photoURLString: photoURLString)
            chipMap.addAnnotation(annotation)
        }
    }
    
    func showFriends(people: NSDictionary) {
        friends.forEach() { friend in
            let personDetails = people.value(forKey: friend) as? NSDictionary
            setUserAnnotation(username: friend, person: personDetails)
        }
    }
    
    func showByClass(people: NSDictionary) {
        classRef.observe(.value) { snapshot in
            let classDict = snapshot.value as? NSDictionary
            self.classesFilter.forEach() { course in
                let peopleInCourse = classDict?[course] as? [String]
                self.showClassmate(people: people, peopleInCourse: peopleInCourse ?? [])
            }
        }
    }
                         
    func showClassmate(people: NSDictionary, peopleInCourse: [String]) {
        peopleInCourse.forEach() { classmate in
            if (!friends.contains(classmate)) {
                let personDetails = people.value(forKey: classmate) as? NSDictionary
                setUserAnnotation(username: classmate, person: personDetails)
            }
        }
    }
    
    func showPeople() {
        profileRef.observe(.value) { snapshot in
            let peopleDict = snapshot.value as? NSDictionary
            switch(self.filters) {
            case Constants.Filters.friends:
                self.showFriends(people: peopleDict!)
                break
            case Constants.Filters.classmates:
                self.showByClass(people: peopleDict!)
                break
            default:
                self.showFriends(people: peopleDict!)
                self.showByClass(people: peopleDict!)
                break
            }
        }
    }
    
    func saveUserLocationToFirebase(longitude: CLLocationDegrees, latitude: CLLocationDegrees) {
        profileRef.observe(.value) { snapshot in
            if (CURRENT_USER != "") {
                let newItemRef = self.profileRef.child(CURRENT_USER)
                newItemRef.child(Constants.DatabaseKeys.longitude).setValue(longitude)
                newItemRef.child(Constants.DatabaseKeys.latitude).setValue(latitude)
            }
        }
    }
    
    // MARK filter stuff
    func setClasses(classesFilter: [String]) {
        self.classesFilter = classesFilter
    }
    
    func setFilterMode(filter: String) {
        self.filters = filter
    }
}
private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 730) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
