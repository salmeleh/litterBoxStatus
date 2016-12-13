//
//  ViewController.swift
//  litterBoxStatus
//
//  Created by Stu Almeleh on 12/7/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scoopLabel: UILabel!
    @IBOutlet weak var cleanBoxLabel: UILabel!

    @IBOutlet weak var firstStartButton: UIButton!
    
    var scoopTimer = Timer()
    var cleanBoxTimer = Timer()
    
    var scoopStartTime = TimeInterval()
    var cleanBoxStartTime = TimeInterval()
    
    var elapsedScoopTime = 0.0
    var elapsedCleanBoxTime = 0.0
    
    var refreshInterval = 0.1
    
    var defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let elapsedScoopTime = defaults.object(forKey: "eST") as! Double
        let elapsedCleanBoxTime = defaults.object(forKey: "eCBT") as! Double
        
        firstStartButton.isHidden = false
    }

    //MARK: press buttons
    @IBAction func firstStartButtonPressed(_ sender: Any) {
        scoopButtonPressed(UIButton)
        cleanBoxButtonPressed(UIButton)
        
        firstStartButton.isHidden = true
    }

    
    @IBAction func scoopButtonPressed(_ sender: Any) {
        scoopStartTime = NSDate.timeIntervalSinceReferenceDate
        
        scoopTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateScoopTimer), userInfo: nil, repeats: true)
    }
    
    @IBAction func cleanBoxButtonPressed(_ sender: Any) {
        cleanBoxStartTime = NSDate.timeIntervalSinceReferenceDate
        
        cleanBoxTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateCleanBoxTimer), userInfo: nil, repeats: true)
        
        scoopButtonPressed(UIButton)
    }
    
    
    
    //MARK: updateTimers
    func updateScoopTimer() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        elapsedScoopTime = currentTime - scoopStartTime
        
        let days = UInt8(elapsedScoopTime / 86400)
        elapsedScoopTime -= (TimeInterval(days) * 86400)
        
        let hours = UInt8(elapsedScoopTime / 3600.0)
        elapsedScoopTime -= (TimeInterval(hours) * 3600)
        
        if hours > 12 {
            //yellow
        }
        else if hours > 24 {
            //orange
        }
        else if hours > 48 {
            //red
        }
        
        let minutes = UInt8(elapsedScoopTime / 60.0)
        elapsedScoopTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedScoopTime)
        elapsedScoopTime -= TimeInterval(seconds)
        
        let fraction = UInt8(elapsedScoopTime * 100)
        
        let timeString = String(format:"%01i:%02i:%02i:%02i.%02i", days, hours, minutes, seconds, fraction)
        
        scoopLabel.text = timeString
        
        
        defaults.set(elapsedScoopTime, forKey: "eST")
    }
    
    
    func updateCleanBoxTimer() {
        let currentTime2 = NSDate.timeIntervalSinceReferenceDate
        elapsedCleanBoxTime = currentTime2 - cleanBoxStartTime
        
        let days2 = UInt8(elapsedCleanBoxTime / 86400)
        elapsedCleanBoxTime -= (TimeInterval(days2) * 86400)
        
        
        let hours2 = UInt8(elapsedCleanBoxTime / 3600.0)
        elapsedCleanBoxTime -= (TimeInterval(hours2) * 3600)
        
        let minutes2 = UInt8(elapsedCleanBoxTime / 60.0)
        elapsedCleanBoxTime -= (TimeInterval(minutes2) * 60)
        
        let seconds2 = UInt8(elapsedCleanBoxTime)
        elapsedCleanBoxTime -= TimeInterval(seconds2)
        
        let fraction2 = UInt8(elapsedCleanBoxTime * 100)
        
        let timeString = String(format:"%01i:%02i:%02i:%02i.%02i", days2, hours2, minutes2, seconds2, fraction2)
        
        cleanBoxLabel.text = timeString
        
        
        defaults.set(elapsedCleanBoxTime, forKey: "eCBT")
    }
    
}

