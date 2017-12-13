//
//  UserClass.swift
//  Safehouse
//
//  Created by Mobile on 10/23/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import MapKit



struct eventStruct{
    var type:eventType = eventType.badTextMessage
    var time:TimeInterval = 0
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var level:Int = 1    // level: 1, 2, or 3 /* 1=green, 2=orange, 3=red */
    
    
    var speed:Int = 0
    var speed_limit:Int = 0
    
    var zoneName:String = ""
    
    var key_phrase:String = ""
    var msg:String = ""
    var sent:Int = 1
    var sender_name:String = "" /* only available when sent=0 */
    
    
    
    func eventTitle() -> String {
        switch type {
        case .enterSafeZone:
            return "Entered A Safe Zone"
        case .leaveSafeZone:
            return "Leave From Safe Zone"
        case .enterUnsafeZone:
            return "Entered An Unsafe Zone"
        case .leaveUnsafeZone:
            return "Leave From Unsafe Zone"
        case .badTextMessage:
            return "Bad Text Message"
        case .speedOver:
            return "Speeding"
        }
    }
    func degreeColor()->UIColor{
        switch level {
        case 1:
            return UIColor.green
        case 2:
            return UIColor.orange
        case 3:
            return UIColor.red
        default:
            return UIColor()
        }
    }
    func image() -> UIImage {
        switch type {
        case .enterSafeZone, .enterUnsafeZone, .leaveSafeZone, .leaveUnsafeZone :
            return #imageLiteral(resourceName: "zoneIcon")
        case .badTextMessage:
            return #imageLiteral(resourceName: "textMsgIcon")
        case .speedOver:
            return #imageLiteral(resourceName: "carIcon")        
        }
    }
    func DateTime() -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a"    //  Nov 1, 9:32 PM
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    func DiffTime() -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a"    //  Nov 1, 9:32 PM
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    func timeAgoSinceDate(numericDates:Bool = true) -> String {
        let date:NSDate = NSDate(timeIntervalSince1970: time)
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
    
}
enum eventType{
    case enterSafeZone
    case leaveSafeZone
    case enterUnsafeZone
    case leaveUnsafeZone
    case badTextMessage
    case speedOver
}
struct zoneStruct{
    var id:String = ""
    var name:String = ""
    var address:String = ""
    var polygon:[CLLocationCoordinate2D] = []
    var safe: Int = 1 //1:safe      0:unsafe
}
class familyMember:NSObject{
    var uid:String = ""
    var phone:String = ""
    var country_code:String = "1"
    var number_part:String = ""
    var email:String = ""
    var name:String = ""
    var photo_url:String = ""
    var type:String  = ""
    var current_location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var current_battery_percent:Int = 100
    var message_count:Int = 0
}
class childStruct:NSObject{
    var uid:String = ""
    var phone:String = ""
    var country_code:String = "1"
    var number_part:String = ""
    var email:String = ""
    var name:String = ""
    var full_name:String = ""
    var photo_url:String = ""
    var current_location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var current_battery_percent:Int = 100
    var current_device_on_off:String = "on" //or "off"
    
    var birthdate:String = ""
    var gender:String = "" // male or "female"
    var height:String = ""
    var weight:String = ""
    var eye_color:String = ""
    var hair_color:String = ""
}
class childSettings:NSObject {
    var notifications:[String:Int] = ["low_battery": 0,
                                      "speeding": 0,
                                      "device_on_off": 0,
                                      "app_installed": 0,
                                      "enter_safe_zone": 0,
                                      "leave_safe_zone": 0,
                                      "enter_unsafe_zone": 0,
                                      "leave_unsafe_zone": 0]
    var key_phrases:[String] = []
}
enum UserState{
    case hasFamily
    case hasName
    case hasEmail
    case hasPassword
    case hasUserId
    case hasFacebookId
    case None
}
class UserClass {
    var uid:String = ""
    var phone:String = ""
    var country_code:String = "1"
    var number_part:String = ""
    var password:String = ""
    var name:String = ""
    var email:String = ""
    var facebook_id:String = ""
    var photo_url:String = ""
    var family_id:String = ""
    var creator_user_id:String = ""
    var signuped:Bool = false
    var signUpFinished:Bool = false
    var userState:UserState = .None
    
    var currVC:UIViewController = UIViewController()
    let ref:DatabaseReference
    let usersReference: DatabaseReference
    
    
    var zones:[zoneStruct] = []
    var familyMembers:[familyMember] = []
    
    var child_id:String = ""
    var child:childStruct = childStruct()
    var childSetting:childSettings = childSettings()
    init() {
        ref = Database.database().reference(fromURL: DBURL)
        usersReference = ref.child("Users")
        
//        do {
//            try Auth.auth().signOut()
//            KeychainWrapper.standard.removeAllKeys()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
//        let result = KeychainWrapper.standard.removeAllKeys()
//        print(result)
      
        if let family_id = KeychainWrapper.standard.string(forKey: KEY_FAMILY_ID){ self.family_id = family_id }
        if let name = KeychainWrapper.standard.string(forKey: KEY_NAME){ self.name = name }
        if let email = KeychainWrapper.standard.string(forKey: KEY_EMAIL){ self.email = email }
        if let password = KeychainWrapper.standard.string(forKey: KEY_PASSWORD){ self.password = password }
        if let facebook_id = KeychainWrapper.standard.string(forKey: KEY_FACEBOOK_ID){ self.facebook_id = facebook_id }
        if let signupFinished = KeychainWrapper.standard.bool(forKey: KEY_SIGNUP_FINISHED){ self.signUpFinished = signupFinished }
        updateState()
    }
    
    func signUpWithFacebook() {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self.currVC) { (result, error) in
            if let error = error {
                showAlert(target: self.currVC, message: "error: Facebook login failed \(error)")
            } else if result?.isCancelled == true {
                print("-----login canceled by user")
            } else {
                self.currVC.startActivityIndicator()
                let credential:AuthCredential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.facebook_id = FBSDKAccessToken.current().userID!
                user.updateState()
                self.signInWithAuthCredential(credential)
            }
        }
    }
    
    func signInWithAuthCredential(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "error: Firebase login failed. \n \(String(describing: error))",title: "Error")
                return
            }
            self.checkUserSignuped()
        })
    }
    func getUserDataFromSnapshot(snapshot: DataSnapshot) {
        let value = snapshot.value as! NSDictionary
        uid = snapshot.key
        name = value["name"] as? String ?? ""
        email = value["email"] as? String ?? ""
        phone = value["phone"] as? String ?? ""
        country_code = value["country_code"] as? String ?? ""
        number_part = value["number_part"] as? String ?? ""
        facebook_id = value["facebook_id"] as? String ?? ""
        photo_url = value["photo_url"] as? String ?? ""
        family_id = value["family_id"] as? String ?? ""
        if family_id != "" {
            signUpFinished = true
        }
        creator_user_id =  value["creator_user_id"] as? String ?? ""
        user.updateState()
        updateKeychainWrapper()
    }
    func getFamilyMembers(completion: @escaping ()->()){
        usersReference.queryOrdered(byChild: "family_id").queryEqual(toValue: family_id).observe(.value, with: { (snapshot) in
            self.familyMembers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as! NSDictionary
                let member:familyMember = familyMember()
                let location:[String : Double] = value["current_location"] as? [String : Double] ?? [:]
                if location.isEmpty{
                    member.current_location = CLLocationCoordinate2D()
                }else{
                    member.current_location = CLLocationCoordinate2DMake(location["lat"]!, location["long"]!)
                }
                member.email = value["email"] as? String ?? ""
                member.name = value["name"] as? String ?? ""
                member.phone = value["phone"] as? String ?? ""
                member.country_code = value["country_code"] as? String ?? ""
                member.number_part = value["number_part"] as? String ?? ""
                member.photo_url = value["photo_url"] as? String ?? ""
                member.type = value["type"] as? String ?? "parent"
                member.uid = child.key
                member.current_battery_percent = Int(round((value["current_battery_percent"] as? Float ?? 1.0) * 100))
                if member.uid == self.uid{
                    member.message_count = 0
                }else{
                    member.message_count = Int(arc4random_uniform(30))
                }
                if member.type == "parent"{
                    self.familyMembers.append(member)
                }else{
                    self.familyMembers.insert(member, at: 0)
                }
            }
            completion()
        })
    }
    func getChildInfo(completion: @escaping ()->()){
        usersReference.child(child_id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! NSDictionary
                let location:[String : Double] = value["current_location"] as? [String : Double] ?? [:]
                if location.isEmpty{
                    self.child.current_location = CLLocationCoordinate2D()
                }else{
                    self.child.current_location = CLLocationCoordinate2DMake(location["lat"]!, location["long"]!)
                }
                self.child.uid = snapshot.key
                self.child.email = value["email"] as? String ?? ""
                self.child.name = value["name"] as? String ?? ""
                self.child.full_name = value["full_name"] as? String ?? ""
                self.child.phone = value["phone"] as? String ?? ""
                self.child.country_code = value["country_code"] as? String ?? ""
                self.child.number_part = value["number_part"] as? String ?? ""
                self.child.photo_url = value["photo_url"] as? String ?? ""
                self.child.current_battery_percent = Int(round((value["current_battery_percent"] as? Float ?? 1.0) * 100))
                self.child.current_device_on_off = value["current_device_on_off"] as? String ?? "on"
                self.child.birthdate = value["birthdate"] as? String ?? ""
                self.child.gender = value["gender"] as? String ?? ""
                self.child.height = value["height"] as? String ?? ""
                self.child.weight = value["weight"] as? String ?? ""
                self.child.eye_color = value["eye_color"] as? String ?? ""
                self.child.hair_color = value["hair_color"] as? String ?? ""
            
                completion()
        })
    }
    func updateChildImage(newImage:UIImage, completion:@escaping (_ photo_url:String)->Void = {_ in }) {
        self.currVC.startActivityIndicator()
        let image = UIImageJPEGRepresentation(newImage, 1)
        Storage.storage().reference().child("userImages").child(self.child_id).putData(image!, metadata: nil, completion: { (data, error) in
            self.currVC.stopActivityIndicator()
            if error != nil{
                showAlert(target: self.currVC, message: "error: Image save failed. \n \(String(describing: error))")
                return
            }
            self.currVC.stopActivityIndicator()
            let photo_url = data?.downloadURL()?.absoluteString
            completion(photo_url!)
        })
    }
    func updateChildData(values:[String:String], completion:@escaping ()->Void = {_ in }) {
        self.currVC.startActivityIndicator()
        print("######self.child.uid",self.child.uid)
        let userReference = usersReference.child(self.child_id)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            self.currVC.stopActivityIndicator()
            if let err = err {
                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                return
            }else{
                completion()
            }
        })
    }
    func getChildSetting(completion: @escaping ()->()){
        let settingReference = ref.child("Settings").child(uid).child(child_id)
        settingReference.observe(.value, with: { (snapshot) in
            if !snapshot.exists(){
                self.childSetting = childSettings()
                completion()
                return
            }
            let value = snapshot.value as! NSDictionary
            
            let notifications:[String : Int] = value["notifications"] as? [String:Int] ?? [:]
            for (key, value) in notifications{
                self.childSetting.notifications[key] = value
            }
            self.childSetting.key_phrases = value["key_phrases"] as? [String] ?? []
            completion()
        })
    }
    
    func updateChildNotificationSetting(values:[String:Int], completion:@escaping ()->Void = {_ in }) {
        let settingReference = ref.child("Settings").child(uid).child(child_id).child("notifications")
        settingReference.updateChildValues(values)
    }
    func updateChildPhrasesSetting(values:[String], completion:@escaping ()->Void = {_ in }) {
        let settingReference = ref.child("Settings").child(uid).child(child_id).child("key_phrases")
        settingReference.removeValue()
        var newValues:[String:String] = [:]
        for i in 0..<values.count{
            newValues["\(i)"] = values[i]
        }
        settingReference.updateChildValues(newValues)
    }
    
   
    func getChildEvents(completion: @escaping ([[String:Any]])->()){
        ref.child("Events").child(child_id).queryOrdered(byChild: "time").observe(.value, with: { (snapshot) in
            var result:[[String:Any]] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                var value:[String:Any] = [:]
                value = child.value as! [String:Any]
                value["id"] = child.key
                result.insert(value, at: 0)
            }
            completion(result)
        })
    }
    func checkUserSignuped() {
        
        //print("-------checkusersignuped func")
        self.usersReference.queryOrdered(byChild: "facebook_id").queryEqual(toValue: self.facebook_id).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currVC.stopActivityIndicator()
            if !snapshot.exists(){  //First signup
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                //print("-------first signup")
                self.switchFromState()
            }else{                 //already signuped
                //print("-------already signuped")
                for child in snapshot.children {
                    self.getUserDataFromSnapshot(snapshot: child as! DataSnapshot)
                }
                let alert = UIAlertController(title: "Alert", message: "You have already user account.\n Please Signin.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.currVC.dismiss(animated: true, completion: nil)
                    self.switchFromState()
                })
                alert.addAction(okAction)
                self.currVC.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    func signIn(password:String) {
        print("##########", email, password)
        self.currVC.startActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (user1, error) in
            
            if error != nil {
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "Sorry, please check your network connection or password is correct.\n Try again! ", title: "SignIn Failed")
                return
            }
            self.uid = (user1?.uid)!
            self.password = password
            self.usersReference.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.currVC.stopActivityIndicator()
                self.getUserDataFromSnapshot(snapshot: snapshot)
                if let viewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapFamilyViewController") as? MapFamilyViewController {
                    if let navigator = self.currVC.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            })
        }
    }
    func switchFromState() {
        
        //self.currVC.stopActivityIndicator()
        switch userState {
        case .None:
            if self.currVC is SignUpPhoneViewController { return }
            if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpPhoneViewController") as? SignUpPhoneViewController {
                if let navigator = self.currVC.navigationController {
                    
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .hasFacebookId:
            if self.currVC is SignUpPasswordViewController { return }
            if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpPasswordViewController") as? SignUpPasswordViewController {
                if let navigator = self.currVC.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .hasPassword:
            if self.currVC is SignUpEmailViewController { return }
            if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpEmailViewController") as? SignUpEmailViewController {
                if let navigator = self.currVC.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .hasEmail:
            if self.currVC is SignUpProfileViewController { return }
            if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpProfileViewController") as? SignUpProfileViewController {
                if let navigator = self.currVC.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .hasName:
            if self.currVC is SignUpJoinFamilyViewController { return }
            if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpJoinFamilyViewController") as? SignUpJoinFamilyViewController {
                if let navigator = self.currVC.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        case .hasFamily:
            if signUpFinished {
                if self.currVC is SignInCheckPassViewController { return }
                if let viewController = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInCheckPassViewController") as? SignInCheckPassViewController {
                    if let navigator = self.currVC.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }else{
                if self.currVC is SignUpPermissionViewController { return }
                if let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpPermissionViewController") as? SignUpPermissionViewController {
                    if let navigator = self.currVC.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        default:
            return
        }
    }
    func updateState() {
        if family_id != ""  { userState = .hasFamily; return}
        if name != ""  { userState = .hasName; return }
        if email != ""  { userState = .hasEmail; return }
        if password != ""  { userState = .hasPassword; return }
        if facebook_id != ""  { userState = .hasFacebookId; return }
        userState = .None;
    }
    func updateKeychainWrapper() {
        KeychainWrapper.standard.set(family_id, forKey: KEY_FAMILY_ID)
        KeychainWrapper.standard.set(name, forKey: KEY_NAME)
        KeychainWrapper.standard.set(email, forKey: KEY_EMAIL)
        KeychainWrapper.standard.set(password, forKey: KEY_PASSWORD)
        KeychainWrapper.standard.set(facebook_id, forKey: KEY_FACEBOOK_ID)
        KeychainWrapper.standard.set(signUpFinished, forKey: KEY_SIGNUP_FINISHED)
    }
    
    func createUserWithEmail() {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                showAlert(target: self.currVC, message: "You can't create user. \n Error details: \(String(describing: error))")
                return
            }
            guard let uid = user?.uid else{
                return
            }
            let userReference = self.usersReference.child(uid)
            let values = ["email": self.email,
                          "facebook_id": self.facebook_id,
                          "last_active": ServerValue.timestamp(),
                          "current_battery_percent": 1,
                          "type": "parent"] as [String : Any]
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                }else{
                    self.uid = uid
                    self.updateState()
                    self.updateKeychainWrapper()
                    self.switchFromState()
                }
            })
            
        }
    }
    func changeUserImageAndName(newImage:UIImage,newName:String) {
        var values:[String:String] = [:]
        let userReference = usersReference.child(uid)
        let image = UIImageJPEGRepresentation(newImage, 0.1)
        Storage.storage().reference().child("userImages").child(uid).putData(image!, metadata: nil, completion: { (data, error) in
            let photo_url = data?.downloadURL()?.absoluteString
            values["photo_url"] = photo_url
            values["name"] = newName
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                }else{
                    self.name = newName
                    self.photo_url = photo_url!
                    self.updateState()
                    self.updateKeychainWrapper()
                    self.switchFromState()
                }
            })
        })
    }
    func changeEmail(newEmail:String, completion:@escaping (_ result:Bool)->Void){
        self.currVC.startActivityIndicator()
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            if error != nil {
                self.currVC.stopActivityIndicator()
                let alert = UIAlertController(title: "Error", message: "Email change failed! \n Error detail: \(String(describing: error))", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.currVC.dismiss(animated: true, completion: nil)
                    completion(false)
                })
                alert.addAction(okAction)
                self.currVC.present(alert, animated: true, completion: nil)
                return
            }
            self.currVC.stopActivityIndicator()
            self.email = newEmail
            self.updateState()
            self.updateKeychainWrapper()
            completion(true)
        })
    }
    func changePassword(newPassword:String, completion:@escaping ()->Void = { }) {
        self.currVC.startActivityIndicator()
        Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error1) in
            self.currVC.stopActivityIndicator()
            if error1 != nil{
                showAlert(target: self.currVC, message: "Password change failed. \n Error: \(String(describing: error1)) ", title: "Error")
                return
            }
            self.password = newPassword
            self.updateState()
            self.updateKeychainWrapper()
            showAlert(target: self.currVC, message: "Your password has changed successfully.", title: "Success", hander: {
                completion()
            })
            
        })
    }
    func updateUserImage(newImage:UIImage, completion:@escaping (_ photo_url:String)->Void = {_ in }) {
        self.currVC.startActivityIndicator()
        let image = UIImageJPEGRepresentation(newImage, 1)
        Storage.storage().reference().child("userImages").child(uid).putData(image!, metadata: nil, completion: { (data, error) in
            if error != nil{
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "error: Image save failed. \n \(String(describing: error))")
                return
            }
            let photo_url = data?.downloadURL()?.absoluteString
            completion(photo_url!)
        })
    }
    func updateUserData(values:[String:String], completion:@escaping ()->Void = {_ in }) {
        self.currVC.startActivityIndicator()
        let userReference = usersReference.child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                return
            }else{
                self.updateValues(values: values)
                self.updateState()
                self.updateKeychainWrapper()
                self.currVC.stopActivityIndicator()
                completion()
            }
        })
    }
    func updateValues(values:[String:String], completion:()->Void = {_ in}){
        for (key, value) in values {
            switch key{
            case "phone":
                self.phone = value
            case "country_code":
                self.country_code = value
            case "number_part":
                self.number_part = value
            case "password":
                self.password = value
            case "name":
                self.name = value
            case "email":
                self.email = value
            case "photo_url":
                self.photo_url = value
            default:
                break
            }
        }
    }
    func changeUserName(newName:String) {
        var values:[String:String] = [:]
        let userReference = usersReference.child(uid)
        values["name"] = newName
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
            }else{
                self.name = newName
                self.updateState()
                self.updateKeychainWrapper()
                self.switchFromState()
            }
        })
    }
    func joinFamily(invite_code: String) {
        let userReference = ref.child("Users").child(uid)
        let familyReference = ref.child("Family")
        //check whether Family for invite code is exist
        familyReference.observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            if snapshot.hasChild(invite_code){  //if family is exist
                let values = ["\(self.uid)": ServerValue.timestamp()]
                familyReference.child("\(invite_code)/members").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                    }else{
                        let values = ["family_id": invite_code]
                        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if let err = err {
                                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                            }else{
                                let alert = UIAlertController(title: "Congratulations!", message: "You are joined to your family group.", preferredStyle: UIAlertControllerStyle.alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                    self.family_id = invite_code
                                    self.updateState()
                                    self.updateKeychainWrapper()
                                    self.switchFromState()
                                })
                                alert.addAction(okAction)
                                self.currVC.present(alert, animated: true, completion: nil)
                            }
                        })
                    }
                })
            }else{      //  nomatched invite code
                showAlert(target: self.currVC, message: "Sorry, We couldn't find your invite Code.  Try again!")
            }
        })
    }
    func createFamily() {
        var invite_code:String = ""
        let userReference = usersReference.child(uid)
        let familyReference = ref.child("Family")
        self.currVC.startActivityIndicator()
        familyReference.observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            repeat {
                invite_code = ShortCodeGenerator.getCode(length: 6)
            }while( snapshot.hasChild(invite_code) );
            
            let values = ["\(self.uid)": ServerValue.timestamp()]
            familyReference.child("\(invite_code)/members").updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    self.currVC.stopActivityIndicator()
                    showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                }else{
                    let values = ["creator_user_id": self.uid]
                    familyReference.child("\(invite_code)").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            self.currVC.stopActivityIndicator()
                            showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                        }else{
                            let values = ["family_id": invite_code]
                            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                if let err = err {
                                    self.currVC.stopActivityIndicator()
                                    showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                                }else{
                                    self.currVC.stopActivityIndicator()
                                    self.family_id = invite_code
                                    let inviteView = self.currVC as! SignUpInviteViewController
                                    inviteView.LblCode.text = invite_code
                                    self.updateState()
                                    self.updateKeychainWrapper()
                                }
                            })
                        }
                    })
                }
            })
        })
    }
    func getZones(completion: @escaping ()->()){
        let zoneRef = ref.child("Family").child(family_id).child("zones")
        zoneRef.observe(.value, with: { (snapshot) in
            self.zones.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as! NSDictionary
                var zone = zoneStruct()
                zone.id = child.key
                zone.name = value["name"] as? String ?? ""
                zone.address = value["address"] as? String ?? ""
                zone.safe = value["safe"] as? Int ?? 1
                let polygon = value["polygon"] as? [[String : Double]] ?? []
                for point in polygon {
                    zone.polygon.append(CLLocationCoordinate2DMake(point["lat"]!, point["long"]!))
                }
                self.zones.append(zone)
            }
            completion()
            //print(self.safeZone, self.unSafeZone)
        })
    }
    func addZone(name: String, address: String, zones: [[String:Double]], safe: Int ) {
        let zonesReference = ref.child("Family").child(self.family_id).child("zones")
        //check whether Family for invite code is exist
        let values = ["name": name,
                      "address": address,
                      "created_by_user_id": uid,
                      "safe": safe,
                      "polygon": zones] as [String : Any]
        zonesReference.childByAutoId().setValue(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
            }else{
                self.currVC.stopActivityIndicator()
                let alert = UIAlertController(title: "Success!", message: "New zone added successfully!", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    let viewControllers: [UIViewController] = self.currVC.navigationController!.viewControllers as [UIViewController]
                    self.currVC.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
                })
                alert.addAction(okAction)
                self.currVC.present(alert, animated: true, completion: nil)
            }
        })
    }
    func updateZone(zone:zoneStruct, completion:@escaping ()->Void = {}) {
        let zoneReference = ref.child("Family").child(family_id).child("zones").child(zone.id)
        //check whether Family for invite code is exist
        var polygon:[[String:Double]] = []
        for point in zone.polygon {
            polygon.append(["lat": point.latitude, "long": point.longitude])
        }
        let values = ["name": zone.name,
                      "address": zone.address,
                      "safe": zone.safe,
                      "polygon": polygon] as [String : Any]
        self.currVC.startActivityIndicator()
        zoneReference.updateChildValues(values) { (error, _) in
            self.currVC.stopActivityIndicator()
            if error != nil {
                showAlert(target: self.currVC, message: "Update zone failed.", title: "Error")
                return
            }
            showAlert(target: self.currVC, message: "Your changes are saved successfully.", title: "Success", hander: {
                completion()
            })
        }
    }
    func deleteZone(zoneId: String ,completion:@escaping ()->Void = {}) {
        let zoneReference = ref.child("Family").child(family_id).child("zones").child(zoneId)
        //check whether Family for invite code is exist
        
        self.currVC.startActivityIndicator()
        zoneReference.removeValue { (error, _) in
            self.currVC.stopActivityIndicator()
            if error != nil {
                showAlert(target: self.currVC, message: "Delete zone failed.", title: "Error")
                return
            }
            showAlert(target: self.currVC, message: "Selected zone is deleted successfully.", title: "Success", hander: {
                completion()
            })
        }
    }
    func deleteAccount(completion: @escaping ()->Void = {}) {
        let familyRef = ref.child("Family").child(family_id).child("members").child(uid)
        let settingsRef = ref.child("Settings").child(uid)
        
        self.currVC.startActivityIndicator()
        familyRef.removeValue { error, _ in
            if error != nil{
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "We can't delete your account from family group", title: "Error")
                return
            }
            settingsRef.removeValue(completionBlock: { (error1, _) in
                if error1 != nil{
                    self.currVC.stopActivityIndicator()
                    showAlert(target: self.currVC, message: "We can't delete your settings from database", title: "Error")
                    return
                }
                self.usersReference.child(self.uid).removeValue(completionBlock: { (error2, _) in
                    if error2 != nil{
                        self.currVC.stopActivityIndicator()
                        showAlert(target: self.currVC, message: "We can't delete your account from database", title: "Error")
                        return
                    }
                    Auth.auth().currentUser?.delete(completion: { (error3) in
                        self.currVC.stopActivityIndicator()
                        if error3 != nil{
                            showAlert(target: self.currVC, message: "We can't delete your account from database", title: "Error")
                            return
                        }
                        showAlert(target: self.currVC, message: "Your account has been deleted successfully!", title: "Success", hander: {
                            do {
                                try Auth.auth().signOut()
                                let result = KeychainWrapper.standard.removeAllKeys()
                                print(result)
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            completion()
                        })
                    })
                })
                
            })
        }
    }
    func signOut(completion:()->Void = {}){
        do {
            try Auth.auth().signOut()
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

func reverseGeocoding(lat:Double, long: Double, completion: @escaping (_ placemark:CLPlacemark)->()) {
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    //let lat: Double = location.coordinate.latitude
    //21.228124
    //let lon: Double = location.coordinate.longitude
    //72.833770
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = lat
    center.longitude = long
    
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    
    
    ceo.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                completion(pm)
//                print(pm.country)
//                print(pm.locality)
//                print(pm.subLocality)
//                print(pm.thoroughfare ?? "")
//                print(pm.postalCode)
//                print(pm.subThoroughfare)
//                var addressString : String = ""
//                if pm.subLocality != nil {
//                    addressString = addressString + pm.subLocality! + ", "
//                }
//                if pm.thoroughfare != nil {
//                   addressString = addressString + pm.thoroughfare! + ", "
//                }
//                if pm.locality != nil {
//                    addressString = addressString + pm.locality! + ", "
//                }
//                if pm.country != nil {
//                    addressString = addressString + pm.country! + ", "
//                }
//                if pm.postalCode != nil {
//                    addressString = addressString + pm.postalCode! + " "
//                }
//                print(addressString)
            }
    })
    
}
