import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var pictureViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var screenSize = UIScreen.main.bounds
    
    // in order to create UICollection View, must have flowLayout
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    // array that will hold URL images of type string
    var imageUrlArray = [String]()
   // array that holds images
    var imageArray = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        confugureLocationServices()
        addDoubleTap()
    
        
        // frame : as big as the pictureView
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        //register a cell for it to use
        //will allow us to deque our cell later in collection view
        collectionView?.register(PictureCell.self, forCellWithReuseIdentifier: "pictureCell")
        // give it a delegate
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.2262285948, alpha: 1)
        pictureView.addSubview(collectionView!)
        
        
        
    }
    
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func animateViewUp(){
        // modifing constraint to make it move up a certain amount
        pictureViewHeightConstraint.constant = 400
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
        cancelAlamofireSessions()
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
        spinner?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // start the animation
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func addProgessLabel() {
        progressLabel = UILabel()
        //x= center of screen , y = 25 points under spinner
        progressLabel?.frame = CGRect(x: (screenSize.width/2) - 120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Helvetica", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "Photos Loading..."
        collectionView?.addSubview(progressLabel!)
        
    }
    
    func removeProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    // using Alamofire to download list of URL's for all the photos
    func retrieveUrls(forAnnotation annotation : DroppingPin , handler : @escaping (_ status : Bool) -> ()) {
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 50)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary < String, AnyObject > else {return}
            // get into photos dictionary
            let photosDict = json["photos"] as! Dictionary < String, AnyObject >
            
            let photosDictArray = photosDict["photo"] as! [Dictionary < String , AnyObject>]
            
            for photo in photosDictArray {
                // look at picture URL to see what it looks like
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                self.imageUrlArray.append(postUrl)
            }
            
            //notify that we are done using all url's
            handler(true)
        }
    }
    
    // download images
    func retrieveImages( handler: @escaping (_ status: Bool) -> ()) {
        
        // cycle thru filled URL array and create an alamofire request
        // to download each image from its URL
        for url in imageUrlArray {
            Alamofire.request(url).responseImage ( completionHandler: { (response) in
                // deal with response and create
                // constant that holds image value
                guard let image = response.result.value else { return }
                
                // use images
                self.imageArray.append(image)
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
        
    }
    
    // canceling almofire sessions for when we
    //scroll down on pictureView and when we drop new pins
    func cancelAlamofireSessions() {
        
        // access singleton class from Alamofire
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            for task in sessionDataTask {
                task.cancel()
            }
            
            // shorter way to do same thing as above
            downloadData.forEach({ $0.cancel()})
        }
    }
    
    
}

// EXTENSIONS

extension MapViewController: MKMapViewDelegate {
    
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
        removeSpinner()
        removeProgressLabel()
        cancelAlamofireSessions()
        
        //blank out arrays and reload data
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgessLabel()
        
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
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            
           // print(self.imageUrlArray)
            
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        // hide spinner
                        self.removeSpinner()
                        // hide label
                        self.removeProgressLabel()
                        
                        // reload collectionView
                        self.collectionView?.reloadData()
                    }
                })
            }
            
            
        }
    }
    
    
    //function that removes the drop pin
    // will call at the beginning of func dropPin
    func removePreviousPin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
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

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as? PictureCell
                              else {return UICollectionViewCell()}  // returning empty cell so app dont crash
        
        // pull out an image from imageArray
        let imageFromIndex = imageArray[indexPath.row]
        // create imageView and add it as subview
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //creating instance of PopVC
        guard let popViewController = storyboard?.instantiateViewController(withIdentifier: "PopViewController") as? PopViewController else {return}
        //pass it image from imageArray
        popViewController.initData(forImage: imageArray[indexPath.row])
        
        //Presenting it
        present(popViewController , animated: true , completion: nil)
        
    }
    
    
}
