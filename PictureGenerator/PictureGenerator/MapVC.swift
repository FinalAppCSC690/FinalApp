
import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
    }
    
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
    }
    
    
}

extension MapVC: MKMapViewDelegate {
    
}
