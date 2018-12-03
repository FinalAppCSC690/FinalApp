
import UIKit

class MapVC: UIViewController {

    @IBOutlet weak var darkBlueBG: UIImageView!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var powerBtn: UIButton!
    @IBOutlet weak var mapHolderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func powerBtnPressed(_ sender: UIButton) {
        mapHolderView.isHidden = false
        darkBlueBG.isHidden = true
        powerBtn.isHidden = true
        welcomeLbl.isHidden = true
    }
    

}

