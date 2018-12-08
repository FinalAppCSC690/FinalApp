import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var pictureViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
 
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        confugureLocationServices()
        addDoubleTap()
        
    }
    
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func animateViewUp(){
        // modifing constraint to make it move up a certain amount
        pictureViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // can swipe down on picture view to hide it again
    func addSwipe(){
        
        // allows us to take note of swipe gesture on screen
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        //set setting for swipe
        swipe.direction = .down
        // add gestureRecognizer to pictureView
        pictureView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown(){
        pictureViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        // give center, style and color for spinner
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 1, green: 0, blue: 0.2262285948, alpha: 1)
        
        // start the animation
        spinner?.startAnimating()
        pictureView.addSubview(spinner!)
        
    }
    
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

// EXTENSIONS

extension MapVC: MKMapViewDelegate {
    
    // changing the dropPin color
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // leave user location alone (blue color)
        if annotation is MKUserLocation {return nil}
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppingPin")
        
        // set color to red
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0, blue: 0.2262285948, alpha: 1)
        //animate pin to drop on mapView
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
   
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else{ return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        //removes previous pins everytime you double tap to drop a new pin
        removePreviousPin()
        animateViewUp()
        addSwipe()
        addSpinner()
        
        
        // drop a pin on the mapview
        let touchPoint = sender.location(in: mapView)
       
         //converting touchPoint into a GPS coordinate
        // can use this later to pass into API and get pictures from that location
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //creating annotation to drop on the map
        let annotation = DroppingPin(coordinate: touchCoordinate, identifier: "droppingPin")
        //adding it to the mapView
        mapView.addAnnotation(annotation)
        
        
        //centering the Pin on the screen
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    //function that removes the drop pin
    // will call at the beginning of func dropPin
    func removePreviousPin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    // a way to check to see if we are authorized to use location
    func confugureLocationServices() {
        
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
