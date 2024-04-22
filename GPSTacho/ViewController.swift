//
//  ViewController.swift
//  GPSTacho
//
//  Created by Manuel Baumgartner on 11/07/2015.
//  Copyright (c) 2015 Application Project Center. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var lastLocation : CLLocation?
    var distance = 0.0
    var lastFrame = 1
    var timer : NSTimer?
    
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbBattery: UILabel!
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var lbDistance: UILabel!
    @IBOutlet weak var lbSpeed: UILabel!
    var image : AnimatedImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        distance = defaults.doubleForKey("distance")
        
        image = AnimatedImage.animatedImageWithName("speedometer.gif")
        imView.setAnimatedImage(image!)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "appClosing:",
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "appResuming:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appClosing", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    
    func timerEvent() {
        lbTime.text = time()
        lbBattery.text = batteryLevel()
        let state = batteryState()
        if state == UIDeviceBatteryState.Charging {
            lbBattery.textColor = UIColor.redColor()
        } else if state == UIDeviceBatteryState.Full {
            lbBattery.textColor = UIColor(red: 0.0, green: 0.85, blue: 0.1, alpha: 1.0)
        } else {
            lbBattery.textColor = UIColor.blackColor()
        }
    }
    
    func time() -> String {
        let currTime = NSDate(timeIntervalSinceNow: 0)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.stringFromDate(currTime)
    }

    func batteryState() -> UIDeviceBatteryState {
        return UIDevice.currentDevice().batteryState
    }
    
    func batteryLevel() -> String {
        let battery = UIDevice.currentDevice().batteryLevel * 100
        let state = UIDevice.currentDevice().batteryState
        if state == UIDeviceBatteryState.Charging {
            return String(format: "C%02.0f", battery) + " %"
        } else {
            return String(format: "%02.0f", battery) + " %"
        }
    }
    
    func appClosing(note : NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(distance, forKey: "distance")
        
        timer?.invalidate()
    }
    
    func appResuming(note : NSNotification) {
        timerEvent()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerEvent"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func handleLongPress(recognizer:UISwipeGestureRecognizer) {
        distance = 0
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(distance, forKey: "distance")
        lbDistance.text = String(format: "%.3f", distance)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            lbSpeed.text = "no GPS"
            break
            
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            lbSpeed.text = "GPS denied"
            break
            
        default:
            lbSpeed.text = "no GPS"
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        imView.startAnimatingGIF(lastFrame, endValue: 0)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last!
        
        if lastLocation != nil {
            let currDist : Double = location.distanceFromLocation(lastLocation!) / 1000 as Double
            if currDist < 10 {
                distance += currDist
                lbDistance.text = String(format: "%.2f", distance)
            }
        }
        
        
        let speed = location.speed
        
        var kmh = speed * 3.6
        if kmh < 0 {
            kmh = 0
        }
        //lbSpeed.text = "\(kmh)"
        if kmh < 10 {
            lbSpeed.text = String(format: "%.1f", kmh)
        } else {
            lbSpeed.text = String(format: "%.0f", kmh)
        }
        
        let toFrame = Int(round(kmh))
        
        if(toFrame != lastFrame && toFrame >= 0 && toFrame <= 150) {
            
            let difference = abs(toFrame - lastFrame)
            if(difference < 10) {
                image?.setDuration(0.1)
            } else if(difference < 20) {
                image?.setDuration(0.08)
            } else if(difference < 30) {
                image?.setDuration(0.06)
            } else if(difference < 40) {
                image?.setDuration(0.04)
            } else if(difference < 50){
                image?.setDuration(0.02)
            } else {
                image?.setDuration(0.01)
            }
            imView.startAnimatingGIF(lastFrame, endValue: toFrame)
            lastFrame = toFrame
        }
        
        
        lastLocation = location
    }
}

