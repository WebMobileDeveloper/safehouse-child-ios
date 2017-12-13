//
//  CameraViewController.swift
//  SafehouseChild
//
//  Created by Delicious on 10/4/17.
//  Copyright © 2017 Delicious. All rights reserved.
//


import UIKit
import AVFoundation
import Foundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
    // Outlets
    @IBOutlet weak var outletCapture: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    
    var photoCaptured = false
    let imagePicker = UIImagePickerController()
    var photo = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(imagePicker, animated: false, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func viewDidLayoutSubviews() {
        addTextButton.layer.cornerRadius = addTextButton.frame.height / 2
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let tempPhoto = (info[UIImagePickerControllerOriginalImage] as? UIImage){
            
            photo = tempPhoto.resizeAndCompressForCheckin(newWidth: 375, maxSize: MAX_UPLOAD_IMAGE_SIZE_FOR_CHECKIN)
            
            imageWidth.constant = Global.screenHeight * photo.size.width / photo.size.height
            image.image = photo
            self.dismiss(animated: true, completion: nil);
            photoCaptured = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func onAddTextButtonClick(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showAddTextView(originText: textLabel.text!)
    }
    @IBAction func onCheckInButtonClick(_ sender: Any) {
        user.checkInImageUpdate(newImage: photo) { (photo_url, request_id) in
            self.startActivityIndicator()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.submitCheckIn(target: self, checkin_id: request_id, photo_url: photo_url, photo_text: self.textLabel.text!, completionHandler: {
                self.stopActivityIndicator()
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
            })
        }
            
    }
    
}
