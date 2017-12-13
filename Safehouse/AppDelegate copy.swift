//
//  AppDelegate.swift
//  Safehouse
//
//  Created by Delicious on 9/18/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import CoreData

import CoreLocation
import Alamofire

import FirebaseCore
import FirebaseAuth
import FBSDKLoginKit
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    var window: UIWindow?
    var gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryStateDidChange:")), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
            if err != nil {
                print("requestAuthorization Failed")
            }else{
                UNUserNotificationCenter.current().delegate = self
                //Messaging.messaging().delegate = self
                DispatchQueue.main.async {
                     application.registerForRemoteNotifications()
                }
            }
        }
        

        //setupLocationManager()
        
        return true
    }
    func ConnectToFCM() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebook =  FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return facebook
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //createRegion(location: lastLocation)
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ConnectToFCM()
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
       // createRegion(location: lastLocation)
        self.saveContext()
    }
    
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Safehouse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func showCheckInWithMom(){
        if let currentViewController = self.window?.rootViewController {
            let mVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "checkInWithMomViewController") as! checkInWithMomViewController
            mVC.modalPresentationStyle = .overCurrentContext
            currentViewController.present(mVC, animated: true, completion: nil)
        }
    }
    
    // Location magager functions   &&&&&&&&&&&&&&&&&&
    var lastLocation:CLLocation = CLLocation()
    var locationManager = CLLocationManager()
    func setupLocationManager(){
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    func createRegion(location:CLLocation?) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
            let regionRadius = 200.0
            let region = CLCircularRegion(center: CLLocationCoordinate2D( latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: "aabb")
            region.notifyOnExit = true
            region.notifyOnEntry = true
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoring(for: region)
        }
        else {
            print("--------System can't track regions")
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("-------Entered Region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("-------Exited Region")
        locationManager.stopMonitoring(for: region)
        /*  MARK:-  REST API access
         */
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    self.locationManager.startUpdatingLocation()
                    return
                }
                let headers:HTTPHeaders = ["Authorization" : "Bearer \(idToken!)", "Accept": "application/json"]
                let parameters = ["user_id": currentUser.uid,
                                  "location": [
                                    "lat":self.lastLocation.coordinate.latitude,
                                    "long":self.lastLocation.coordinate.longitude
                    ]] as [String : Any]
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/location"
                
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response(completionHandler: { (response) in
                    self.locationManager.startUpdatingLocation()
                })
            })
        }else{
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lastLocation = location!
        self.createRegion(location: lastLocation)
    }
    //-------------&&&&&&&&&&&&&&&&&&
    //  Battery Notification functions &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    var batteryState: UIDeviceBatteryState {
        return UIDevice.current.batteryState
    }
    func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        switch batteryState {
        case .unplugged, .unknown:
            print("-----not charging")
        case .charging, .full:
            print("-----charging or full")
        }
    }
    
    func batteryLevelDidChange(notification: NSNotification){
        // The battery's level did change (98%, 99%, ...)
        print("-----Request Sent")
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    return
                }
                let headers:HTTPHeaders = [
                    "Authorization" : "Bearer \(idToken!)" ,
                    "Accept": "application/json"
                ]
                let parameters = [
                    "user_id": currentUser.uid,
                    "location": [
                        "lat":self.lastLocation.coordinate.latitude,
                        "long":self.lastLocation.coordinate.longitude
                    ],
                    "type":"battery_perc_change",
                    "battery_pec": self.batteryLevel
                    ] as [String : Any]
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/event"
                Alamofire.request(url,
                                  method: HTTPMethod.post,
                                  parameters: parameters,
                                  encoding: JSONEncoding.default,
                                  headers: headers)
                    .response(completionHandler: { (response) in
                    })
            })
        }
    }
    //------------&&&&&&&&&&&&&&&&&&&&&&
}


// MARK: - Push notification

extension AppDelegate: UNUserNotificationCenterDelegate {
    
//    func registerPushNotification(_ application: UIApplication) {
//        // For iOS 10 display notification (sent via APNS)
//        print("######  1")
//        UNUserNotificationCenter.current().delegate = self
//
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
//
//        // For iOS 10 data message (sent via FCM)
//        Messaging.messaging().delegate = self
//    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //When the notifications of this code worked well, there was not yet.
        print("######  2")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // [START receive_message]
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // Print message ID.
//        print("######  3")
//        if let messageID = userInfo[gcmMessageIDKey] {
//            debugPrint("Message ID: \(messageID)")
//        }
//
//        // Print full message.
//        debugPrint(userInfo)
//    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print("######  4")
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//
//        // Print full message.
//        debugPrint(userInfo)
//
//        completionHandler(.newData)
//    }
    
    // showing push notification
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
//            print("######  5")
////            let routerManager = RouterManager()
////            routerManager.launchRouting(userInfo)
//            print(userInfo)
//        }
//        completionHandler()
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String : Any] {
            for (key, val) in userInfo{
                print("#####key: ", key, "   val: ", val)
            }
            
//            if let categoryID = userInfo["categoryID"] as? String {
////                if categoryID == RouterManager.Categories.newMessage.id {
////                    if let currentConversation = ChatGeneralManager.shared.currentChatPersonalConversation, let dataID = userInfo["dataID"] as? String  {
////                        // dataID is conversationd id for newMessage
////                        if currentConversation.id == dataID {
////                            completionHandler([])
////                            return
////                        }
////                    }
////                }
//                print(categoryID)
//            }
            if let badge = notification.request.content.badge {
                print("\n #####  badge:  ", badge)
                //AppBadgesManager.shared.pushNotificationHandler(userInfo, pushNotificationBadgeNumber: badge.intValue)
            }
        }
        completionHandler([.alert,.sound, .badge])
    }
    
}

// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        print("##### newToken: ", newToken ?? "")
        ConnectToFCM()
    }
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData)
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("######    messaging   \n",messaging)
        print("######  remoteMessage:  \n",remoteMessage)
    }

}

