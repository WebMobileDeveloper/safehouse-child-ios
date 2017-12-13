//
//  emergencyViewController.swift
//  SafehouseChild
//
//  Created by Delicious on 10/5/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit


class emergencyViewController: UIViewController,SRCountdownTimerDelegate {
    
    
    @IBOutlet weak var countdownTimer: SRCountdownTimer!

    @IBAction func onCall911ButtonClick(_ sender: Any) {
        countdownTimer.pause()
        if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func onCancelButtonClick(_ sender: Any) {
        countdownTimer.pause()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Medium", size: 80.0)
        countdownTimer.labelTextColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
        countdownTimer.timerFinishingText = ""
        countdownTimer.lineWidth = 8
        countdownTimer.displayInterval = 2
        countdownTimer.lineColor = UIColor(red: 241/255, green: 79/255, blue: 99/255, alpha: 1)
        countdownTimer.trailLineColor = UIColor.clear
        countdownTimer.start(beginingValue: 10, interval: 1)
        countdownTimer.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func timerDidEnd() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showRecordingView()
    }
    

}
