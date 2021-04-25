//
//  ForgetDirectlyDeviceViewController.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 23.04.2021.
//

import UIKit

class ForgetDirectlyDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Action
    
    @IBAction func forgetDeviceButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "forgetDirectlyDevice", sender: self)
    }

}
