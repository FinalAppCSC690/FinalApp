//
//  ViewController.swift
//  PictureGenerator
//
//  Created by Ahmad Hamed Rangeen on 11/29/18.
//  Copyright © 2018 Ahmad Hamed Rangeen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var darkBlueBG: UIImageView!
    @IBOutlet weak var powerBtn: UIButton!
    @IBOutlet weak var mapview: UIView!
    @IBOutlet weak var welcomeLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    @IBAction func powerBtnPressed(_ sender: UIButton) {
        darkBlueBG.isHidden = true
        powerBtn.isHidden = true
        welcomeLbl.isHidden = true
        mapview.isHidden = false
    }
}

