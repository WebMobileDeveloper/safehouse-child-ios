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
    var country_code:String = "US"
    var number_part:String = ""
    var email:String = ""
    var name:String = ""
    var photo_url:String = ""
    var type:String  = ""
    var current_location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var current_battery_percent:Int = 100
    var message_count:Int = 0
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
struct checkRequestStruct{
    var request_id:String = ""
    var parent_id:String = ""
    var parent_name:String = ""
    var seen:Int = 0
}

class UserClass{
    var uid:String = ""
    var phone:String = ""
    var country_code:String = "US"
    var number_part:String = ""
    var password:String = ""
    var name:String = ""
    var email:String = ""
    var facebook_id:String = ""
    var photo_url:String = ""
    var family_id:String = ""
    var signuped:Bool = false
    var signUpFinished:Bool = false
    var userState:UserState = .None
    var current_location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var currVC:UIViewController = UIViewController()
    let ref:DatabaseReference
    
    
    var checkRequest:[checkRequestStruct] = []
    var sentCheckInStatus = false
    var emergencyRequestStatus = false
    
    var zones:[zoneStruct] = []
    var familyMembers:[familyMember] = []
    
    
    //MARK: -- Basic Methods -----------------
    
    init() {
        ref = Database.database().reference(fromURL: DBURL)
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
    
    
    // MARK: -- Auth Methods -------------
    
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
    
    func checkUserSignuped() {
        let usersReference = ref.child("Users")
        usersReference.queryOrdered(byChild: "facebook_id").queryEqual(toValue: self.facebook_id).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currVC.stopActivityIndicator()
            if !snapshot.exists(){  //First signup
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                self.switchFromState()
            }else{                 //already signuped
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
    
    func createUserWithEmail() {
        let userReference = ref.child("Users").child(uid)
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                showAlert(target: self.currVC, message: "You can't create user. \n Error details: \(String(describing: error))")
                return
            }
            guard let uid = user?.uid else{
                return
            }
            let values = ["email": self.email,
                          "facebook_id": self.facebook_id,
                          "last_active": ServerValue.timestamp(),
                          "current_battery_percent": 1,
                          "type": "child"] as [String : Any]
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
    
    func signIn(password:String) {
        
        self.currVC.startActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (user1, error) in
            if error != nil {
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "Sorry, please check your network connection or password is correct.\n Try again! ", title: "SignIn Failed")
                return
            }
            self.uid = (user1?.uid)!
            self.password = password
            let userReference = self.ref.child("Users").child(self.uid)
            userReference.observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    func signOut(completion:()->Void = {}){
        do {
            try Auth.auth().signOut()
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    func deleteAccount(completion: @escaping ()->Void = {}) {
        let familyRef = ref.child("Family").child(family_id).child("members").child(uid)
        let settingsRef = ref.child("Settings").queryOrdered(byChild: uid)
        let userReference = ref.child("Users").child(self.uid)
        self.currVC.startActivityIndicator()
        familyRef.removeValue { error, _ in
            if error != nil{
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "We can't delete your account from family group", title: "Error")
                return
            }
            settingsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    for node in snapshot.children {
                        let tempSnap = node as! DataSnapshot
                        self.ref.child("Settings").child(tempSnap.key).child(self.uid).removeValue()
                    }
                }
                
            })
            userReference.removeValue(completionBlock: { (error2, _) in
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
        }
    }
    
    
    
    //MARK: -- Database Ref Methods ---------
    
    func getUserDataFromSnapshot(snapshot: DataSnapshot) {
        let value = snapshot.value as! NSDictionary
        uid = snapshot.key
        name = value["name"] as? String ?? ""
        email = value["email"] as? String ?? ""
        phone = value["phone"] as? String ?? ""
        country_code = value["country_code"] as? String ?? "US"
        number_part = value["number_part"] as? String ?? ""
        facebook_id = value["facebook_id"] as? String ?? ""
        photo_url = value["photo_url"] as? String ?? ""
        family_id = value["family_id"] as? String ?? ""
        if family_id != "" {
            signUpFinished = true
        }
        user.updateState()
        updateKeychainWrapper()
    }
    func getCheckInRequests(completionHandler:@escaping ()->Void = {}){
        let checkinRef = ref.child("Users").child(uid).child("checkins")
        
        checkinRef.observe(DataEventType.value, with: { snapshot in
            self.checkRequest.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as! NSDictionary
                let seen = value["seen"] as? Int ?? 0
                if seen == 0 {
                    var newRequest = checkRequestStruct()
                    newRequest.request_id = child.key
                    newRequest.parent_id = value["parent_id"] as? String ?? ""
                    newRequest.seen = seen
                    for member in self.familyMembers {
                        if member.uid == newRequest.parent_id{
                            newRequest.parent_name = member.name
                            break
                        }
                    }                   
                    self.checkRequest.append(newRequest)
                }
            }
            completionHandler()
        })
    }
    func checkInImageUpdate(newImage:UIImage, completionHandeler:@escaping (_ photo_url:String, _ request_id:String)->Void = {_ in }){
        self.currVC.startActivityIndicator()
        let request_id = checkRequest[0].request_id
        let reqReference = self.ref.child("Users").child(uid).child("checkins").child(request_id)
        let image = UIImageJPEGRepresentation(newImage, 1)
        Storage.storage().reference().child("checkinImages").child(uid).child(request_id).putData(image!, metadata: nil, completion: { (data, error) in
           
            if error != nil{
                self.currVC.stopActivityIndicator()
                showAlert(target: self.currVC, message: "error: Image save failed. \n \(String(describing: error))")
                return
            }
            
            reqReference.updateChildValues(["seen": 1], withCompletionBlock: { (err, ref) in
                self.currVC.stopActivityIndicator()
                if let err = err {
                    showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                    return
                }else{
                    let photo_url = data?.downloadURL()?.absoluteString
                    completionHandeler(photo_url!,request_id)
                }
            })
        })
    }
    
    //MARK:- ------- emergency Method ------------------
    
    func uplaodEmergencyVoice(url:URL, completionHandeler:@escaping (_ audio_url:String)->Void = {_ in }){
        self.currVC.startActivityIndicator(style: UIActivityIndicatorViewStyle.gray)
        Storage.storage().reference().child("emergency").child(uid).putFile(from: url, metadata: nil, completion: { (data, error) in
            self.currVC.stopActivityIndicator()
            if error != nil{
                showAlert(target: self.currVC, message: "error: Audio upload failed. \n \(String(describing: error))")
                return
            }
            let download_url = data?.downloadURL()?.absoluteString
            completionHandeler(download_url!)
        })
    }
    //MARK: ------ Profile Methods-----
    
    func updateUserImage(newImage:UIImage, uid:String, completion:@escaping (_ photo_url:String)->Void = {_ in }) {
        let image = UIImageJPEGRepresentation(newImage, 1)
        Storage.storage().reference().child("userImages").child(uid).putData(image!, metadata: nil, completion: { (data, error) in
            self.currVC.stopActivityIndicator()
            if error != nil{
                showAlert(target: self.currVC, message: "error: Image save failed. \n \(String(describing: error))")
                return
            }
            let photo_url = data?.downloadURL()?.absoluteString
            completion(photo_url!)
        })
    }
    func updateUserData(values:[String:String],uid:String, completion:@escaping ()->Void = {_ in }) {
        self.currVC.startActivityIndicator()
        let userReference = ref.child("Users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            self.currVC.stopActivityIndicator()
            if let err = err {
                showAlert(target: self.currVC, message: "error: Firebase connection failed \(err)")
                return
            }else{
                if uid == self.uid{
                    self.updateValues(values: values)
                    self.updateState()
                    self.updateKeychainWrapper()
                }
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
    func changeEmail(newEmail:String, completion:@escaping (_ result:Bool)->Void){
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
    
    //MARK: ------ Family Group Methods-----
    
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
    
    
    // MARK: -------   Family Member Methods --------------
    
    func getFamilyMembers(completion: @escaping ()->()){
        let usersReference = ref.child("Users")
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
                member.country_code = value["country_code"] as? String ?? "US"
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
    // MARK: -------   Zone Methods  ----------
    
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
    
    // MARK:- -------Rest API Methods  -------------
    
    
   
}
