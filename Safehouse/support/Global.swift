//
//  Global.swift
//  Safehouse
//
//  Created by Delicious on 9/21/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import MapKit


var emergencySent = false
let KEY_FAMILY_ID = "KEY_FAMILY_ID"
let KEY_NAME = "KEY_NAME"
let KEY_EMAIL = "KEY_EMAIL"
let KEY_PASSWORD = "KEY_PASSWORD"
let KEY_FACEBOOK_ID = "KEY_FACEBOOK_ID"
let KEY_SIGNUP_FINISHED = "KEY_SIGNUP_FINISHED"
var user:UserClass = UserClass()

let MAX_UPLOAD_IMAGE_SIZE = 10 * 1024
let MAX_UPLOAD_IMAGE_SIZE_FOR_CHECKIN = 100 * 1024
let PROFILE_IMAGE_WIDTH:CGFloat = 200

let DBURL = "https://safehouse-488e5.firebaseio.com/"

class Global{
    static let screenSize = UIScreen.main.bounds
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let Y_ratio = UIScreen.main.bounds.height / 667
    static let X_ratio = UIScreen.main.bounds.width / 375
}


// MARK:- degreesToRadians
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
extension Double {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(Double.pi) / 180.0
    }
}

extension UILabel {
    func createCopy() -> UILabel {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: archivedData) as! UILabel
    }
}


func showAlert(target: UIViewController, message: String, title:String = "Alert", hander:@escaping ()->Void = {}) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        hander()
    }))
    var subView = alert.view.subviews.first!
    subView = subView.subviews.first!
    subView = subView.subviews.last!
    //alert.view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    subView.backgroundColor = UIColor.white
    target.present(alert, animated: true, completion: nil)
}
func showChoiceAlert(target:UIViewController){
    let choiceAlert = UIAlertController(title: "Select type", message: "Select your profile image type.", preferredStyle: UIAlertControllerStyle.alert)
    
    choiceAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction!) in
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true;
        imagePickerController.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        target.present(imagePickerController, animated: true, completion: nil)
    }))
    
    choiceAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true;
        imagePickerController.delegate = target as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        target.present(imagePickerController, animated: true, completion: nil)
    }))
    target.present(choiceAlert, animated: true, completion: nil)
}


func reverseGeocoding(lat:Double, long: Double, completionHandler: @escaping (CLPlacemark?)
    -> Void ) {
    // Use the last reported location.
    
        
        // Look up the location and pass it to the completion handler
        let lastLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = placemarks![0]
                    completionHandler(pm)
                }else{
                    completionHandler(nil)
                }
            }
            else {
                completionHandler(nil)
            }
        })
    
}




