//
//  recordingViewController.swift
//  SafehouseChild
//
//  Created by Delicious on 10/5/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import AVFoundation


class recordingViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    
    var audioRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let recordSettings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
        AVNumberOfChannelsKey: 1,
        AVSampleRateKey : 44100.0
        ] as [String : Any]
    
    let filePath =  NSTemporaryDirectory().appending("safeHouseAudioRecording.m4a")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: filePath), settings: recordSettings)
            
            self.audioRecorder.delegate = self
            self.audioRecorder.isMeteringEnabled = true
            _ = self.audioRecorder.record(forDuration: 5.0)
            self.audioRecorder.prepareToRecord()
            self.audioRecorder.record()
            if self.audioRecorder.isRecording == true {
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioMeter(timer:)), userInfo: nil, repeats: true)
            }
        } catch {
            showAlert(target: self, message: "Sound recording failed.", title: "Error", hander: {
                let previousView = self.presentingViewController as! UINavigationController
                self.dismiss(animated: true, completion:  {
                    let viewControllers: [UIViewController] = previousView.navigationController!.viewControllers as [UIViewController]
                    previousView.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
                });
            })
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording \(flag)")
        // ios8 and later
        self.stateLabel.text = "Recording finished!"
        
        let alert = UIAlertController(title: "Recoding Finished!", message: "Are you sure want to send your voice to your Mom?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.sendAlert()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {action in
            self.cancelAlert()
        }))
        self.present(alert, animated:true, completion:nil)
    }
    func sendAlert() {
        self.stateLabel.text = "Request sending ..."
        user.uplaodEmergencyVoice(url: URL(fileURLWithPath: self.filePath) , completionHandeler: { (download_url) in
            self.startActivityIndicator(style: UIActivityIndicatorViewStyle.gray)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendEmergencyRequest(target: self, audio_url: download_url, completionHandler: {
                self.stopActivityIndicator()
                let preVC = self.presentingViewController as! UINavigationController
                self.dismiss(animated: true) {
                    emergencySent = true
                    let viewControllers: [UIViewController] = preVC.viewControllers as [UIViewController]
                    preVC.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
                }
            })
        })
    }
    func cancelAlert(){
        self.audioRecorder?.deleteRecording()
        let preVC = self.presentingViewController as! UINavigationController
        self.dismiss(animated: true) {
            print(preVC.viewControllers)
            let viewControllers: [UIViewController] = preVC.viewControllers as [UIViewController]
            preVC.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
        }
    }
    
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("\(String(describing: error?.localizedDescription))")
        showAlert(target: self, message: "Audio recording failed.", title: "Error") {
            let previousView = self.presentingViewController as! UINavigationController
            self.dismiss(animated: true, completion:  {
                let viewControllers: [UIViewController] = previousView.viewControllers as [UIViewController]
                previousView.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
            });
        }
    }
    
    func updateAudioMeter(timer:Timer) {
        if  self.audioRecorder.isRecording {
//            let dFormat = "%02d"
//            let min:Int = Int(self.audioRecorder.currentTime / 60)
            let sec:Float = Float(self.audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            progress.progress = sec / 5.0
            self.audioRecorder.updateMeters()
        }
    }
   
}

