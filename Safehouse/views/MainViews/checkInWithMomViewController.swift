//
//  checkInWithMomViewController.swift
//  SafehouseChild
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class checkInWithMomViewController: UIViewController {
    
    @IBAction func onCheckNowButtonTapped(_ sender: Any) {
        let previousView = self.presentingViewController as! UINavigationController
        self.dismiss(animated: true, completion:  {
            if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
                previousView.pushViewController(viewController, animated: false)
            }
        });
    }
    @IBAction func onCheckLaterButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
