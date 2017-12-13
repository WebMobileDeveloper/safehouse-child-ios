//
//  addTextViewController.swift
//  SafehouseChild
//
//  Created by Mobile on 10/17/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit

class addTextViewController: UIViewController {
    
    var originText:String = ""
    @IBOutlet weak var btnAddText: UIButton!
    @IBOutlet weak var btnNoText: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBAction func onAddTextButtonTapped(_ sender: Any) {
        // Get the presenting/previous view
        let previousView = self.presentingViewController as! UINavigationController
        self.dismiss(animated: true, completion:  {
            let cameraview = previousView.viewControllers[previousView.viewControllers.count - 1] as! CameraViewController
            cameraview.textLabel.text = self.messageTextView.text
        });
    }
    @IBAction func onNoTextButtonTapped(_ sender: Any) {
        let previousView = self.presentingViewController as! UINavigationController
        self.dismiss(animated: true, completion:  {
            let cameraview = previousView.viewControllers[previousView.viewControllers.count - 1] as! CameraViewController
            cameraview.textLabel.text = ""
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.text = originText
        messageTextView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        btnAddText.layer.cornerRadius = btnAddText.frame.height / 2
        btnNoText.layer.cornerRadius = btnNoText.frame.height / 2
    }
}

