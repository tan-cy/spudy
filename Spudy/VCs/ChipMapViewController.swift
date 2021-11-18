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
import CoreData

protocol MapFilterSetter {
    func setClasses (classesFilter: [String])
    func setFilterMode (filter: String)
    func selfStudyMode (selfStudy: Bool)
    func focusOnUser (longitude: Double, latitude: Double)
}

protocol TappedUser {
    func tappedUser (view: MKAnnotationView)
}

class ChipMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MapFilterSetter {

    let locationManager = CLLocationManager()
    var profileRef: DatabaseReference!
    var classRef: DatabaseReference!
    
    var selfStudy: Bool! = false
    var filters: String! = Constants.Filters.everyone
    var friends: [String]!
    var classmates: [String]!
    var classesFilter: [String] = []
    var classes: [String]!
    
    @IBOutlet weak var chipMap: MKMapView!
    @IBOutlet weak var selfStudyMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipMap.isZoomEnabled = true
        getUsername()
        profileRef = Database.database().reference(withPath: Constants.DatabaseKeys.profilePath)
        classRef = Database.database().reference(withPath: Constants.DatabaseKeys.classesPath)

        getPeopleFromDatabase()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Set location to UT
        let initialLocation = CLLocation(latitude: 30.285607, longitude: -97.738202)
        chipMap.centerToLocation(initialLocation)
        chipMap.delegate = self
        setupLocationManager()
        checkLocationServices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.filterSegueIdentifier,
            let destination = segue.destination as? ChipMapFiltersViewController {
            destination.mapFilterDelegate = self
            destination.totalClasses = classes
            destination.filterClasses = classesFilter
            destination.showPeopleFilter = filters
        } else if segue.identifier == Constants.Segues.chipSegueIdentifier,
            let destination = segue.destination as? ProfileViewController,
            let annotation = sender as? UserMKAnnotation {
            destination.userToGet = annotation.subtitle!
        }
    }
    
    func getPeopleFromDatabase() {
        profileRef.observe(.value) { snapshot in
            let profiles = snapshot.value as? NSDictionary
            let user = profiles?[CURRENT_USERNAME] as? NSDictionary
            self.friends = user?[Constants.DatabaseKeys.friends] as? [String] ?? []
            self.classes = user?[Constants.DatabaseKeys.classes] as? [String] ?? []
            self.classesFilter = self.classes
        }
    }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // need to enable zooming by changing these coords
//        if ((mapView.region.span.latitudeDelta > 30.291983 ) || (mapView.region.span.longitudeDelta > -97.742638) ) {
//            let centerCoord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(30.285607, -97.738202);
//            let UTRegion:MKCoordinateRegion = MKCoordinateRegion(center: centerCoord, latitudinalMeters: 700, longitudinalMeters: 700)
//            mapView.setRegion(UTRegion, animated: true);
//        }
//    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("tapped annotation")
//        let location = view.annotation?.coordinate
//        let region = MKCoordinateRegion.init(center: location!, latitudinalMeters: 200, longitudinalMeters: 200)
//        chipMap.setRegion(region, animated: true)
//        let annotation = (view.annotation as? UserMKAnnotation)
//        if let selectedUsername = annotation?.subtitle,
//            selectedUsername != CURRENT_USERNAME {
//            performSegue(withIdentifier: Constants.Segues.chipSegueIdentifier, sender: annotation)
//        }
//    }
    @objc func tappedUser(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! MKAnnotationView
        let location = view.annotation?.coordinate
        let region = MKCoordinateRegion.init(center: location!, latitudinalMeters: 200, longitudinalMeters: 200)
        chipMap.setRegion(region, animated: true)
        let annotation = (view.annotation as? UserMKAnnotation)
        if let selectedUsername = annotation?.subtitle,
            selectedUsername != CURRENT_USERNAME {
            performSegue(withIdentifier: Constants.Segues.chipSegueIdentifier, sender: annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let userAnnotationIdentifier =  "userAnnotationIdentifier"
        var annotationView = chipMap.dequeueReusableAnnotationView(withIdentifier:userAnnotationIdentifier)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: userAnnotationIdentifier)
            annotationView?.canShowCallout = true
            
//            let button = UIButton(primaryAction: UIAction(handler: #selector(tappedUser(view: annotationView))))
//            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//            annotationView!.rightCalloutAccessoryView = button
            annotationView?.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedUser(_:)))
            annotationView?.addGestureRecognizer(tap)
            let userAnnotation = annotation as! UserMKAnnotation
            annotationView?.addSubview(userAnnotation.imageView)
        } else {
            annotationView?.annotation = annotation
        }
        
        
        
//        annotationView?.image = userAnnotation.image
        
            
        return annotationView
    }
    
    
    // MARK CURRENT USER LOCATION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let userLatitude = location.coordinate.latitude
        let userLongitude = location.coordinate.longitude
        
        saveUserLocationToFirebase(longitude: userLongitude, latitude: userLatitude)
    }
   
    func checkLocationAuthorization() {
        let controller = UIAlertController(
            title: "Cannot determine location",
            message: "There was an issue locating you" ,
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil))
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorized, .authorizedAlways:
            chipMap.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            controller.message = "Location services must be turned on to see other users"
            present(controller, animated: true, completion: nil)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            present(controller, animated: true, completion: nil)
            break
        default:
            fatalError()
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
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
        
        self.showPeople()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    // MARK Map Annotations
    func setUserAnnotation(username: String, person: NSDictionary?, pinColor: UIColor) {
        let lat = person?[Constants.DatabaseKeys.latitude] as? Double ?? nil
        let long = person?[Constants.DatabaseKeys.longitude] as? Double ?? nil
        // add person to map
        if (lat != nil && long != nil) {
            let name = person?[Constants.DatabaseKeys.name] as! String
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            let photoURLString = person?[Constants.DatabaseKeys.photo] as? String
            let annotation = UserMKAnnotation(name: name, username: username, coord: coordinate, photoURLString: photoURLString, pinColor: pinColor)
            chipMap.addAnnotation(annotation)
        }
    }
    
    func showFriends(people: NSDictionary) {
        // show all friends
        friends.forEach() { friend in
            let personDetails = people.value(forKey: friend) as! NSDictionary
            let locationSetting = (personDetails[Constants.DatabaseKeys.settings] as! NSDictionary)[Constants.DatabaseKeys.locationSetting] as! String
            if (locationSetting != Constants.LocationSettings.none.rawValue) {
                setUserAnnotation(username: friend, person: personDetails, pinColor: UIColor.red)
            }
        }
    }
    
    func showByClass(people: NSDictionary) {
        classRef.observe(.value) { snapshot in
            let classDict = snapshot.value as? NSDictionary
            self.classesFilter.forEach() { course in
                let peopleInCourse = (classDict?.value(forKey: course) as? NSDictionary)?.value(forKey: "students") as? [String]
                self.showClassmate(people: people, peopleInCourse: peopleInCourse ?? [])
            }
        }
    }
                         
    func showClassmate(people: NSDictionary, peopleInCourse: [String]) {
        peopleInCourse.forEach() { classmate in
            if (!friends.contains(classmate) && classmate != CURRENT_USERNAME) {
                let personDetails = people.value(forKey: classmate) as! NSDictionary
                let locationSetting = (personDetails[Constants.DatabaseKeys.settings] as! NSDictionary)[Constants.DatabaseKeys.locationSetting] as! String
                if (locationSetting != Constants.LocationSettings.none.rawValue) {
                    setUserAnnotation(username: classmate, person: personDetails, pinColor: UIColor.cyan)
                }
            }
        }
    }
    
    func showPeople() {
        profileRef.observe(.value) { snapshot in
            let profiles = snapshot.value as? NSDictionary
            let user = profiles?[CURRENT_USERNAME] as? NSDictionary
            self.selfStudy =  ((user?[Constants.DatabaseKeys.settings] as? NSDictionary)?[Constants.DatabaseKeys.selfStudy] as! Bool)
        }
        clearMapOfAnnotations()
        if (selfStudy) {
            self.selfStudyMessage.isHidden = false
            self.chipMap.isHidden = true
        } else {
            self.selfStudyMessage.isHidden = true
            self.chipMap.isHidden = false
            profileRef.observe(.value) { snapshot in
                let peopleDict = snapshot.value as? NSDictionary
                switch(self.filters) {
                case Constants.Filters.friends:
                    self.showFriends(people: peopleDict!)
                    break
                case Constants.Filters.classmates:
                    self.showByClass(people: peopleDict!)
                    break
                case Constants.Filters.everyone:
                    self.showFriends(people: peopleDict!)
                    self.showByClass(people: peopleDict!)
                    break
                default:
                    print("filters has gone wrong ")
                    break
                }
            }
        }
        
    }
    
    func saveUserLocationToFirebase(longitude: CLLocationDegrees, latitude: CLLocationDegrees) {
        if (CURRENT_USERNAME != "") {
            let newItemRef = self.profileRef.child(CURRENT_USERNAME)
            newItemRef.child(Constants.DatabaseKeys.longitude).setValue(longitude)
            newItemRef.child(Constants.DatabaseKeys.latitude).setValue(latitude)
        } else {
            print("user not found")
        }
    }
    
    func clearMapOfAnnotations() {
        self.chipMap.annotations.forEach {
          if !($0 is MKUserLocation) {
            self.chipMap.removeAnnotation($0)
          }
        }
    }
    
    // MARK filter stuff
    func setClasses(classesFilter: [String]) {
        self.classesFilter = classesFilter
        showPeople()
    }
    
    func setFilterMode(filter: String) {
        self.filters = filter
        showPeople()
    }
    
    func selfStudyMode(selfStudy: Bool) {
        self.selfStudy = selfStudy
        showPeople()
    }
    
    func focusOnUser(longitude: Double, latitude: Double) {
        chipMap.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: 200)
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
