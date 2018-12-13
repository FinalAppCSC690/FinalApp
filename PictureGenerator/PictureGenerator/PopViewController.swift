import UIKit

class PopViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var PopImageView: UIImageView!
    
    var passedImage : UIImage!
    
    func initData (forImage image : UIImage){
        
        self.passedImage = image
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PopImageView.image = passedImage
        addDoubleTap()

    }
    
    
    // adding a function for UIGestureRecognizer
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer (target: self, action: #selector(screenDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenDoubleTapped () {
        dismiss(animated: true, completion: nil)
    }
    
    }
