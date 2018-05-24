//
//  ViewController.swift
//  litterBoxStatus
//
//  Created by Stu Almeleh on 12/7/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    //outlets
    @IBOutlet weak var scoopLabel: UILabel!
    @IBOutlet weak var cleanBoxLabel: UILabel!

    @IBOutlet weak var firstStartButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    //variables
    var scoopTimer = Timer()
    var cleanBoxTimer = Timer()
    
    var scoopStartTime = TimeInterval()
    var cleanBoxStartTime = TimeInterval()
    
    var elapsedScoopTime = 0.0
    var elapsedCleanBoxTime = 0.0
    
    var refreshInterval = 0.1

    var isGrantedNotificationAccess:Bool = false
    
    
    //MARK: vDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check for notification permission
        //func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted,error) in
            if granted {
                print("Notification Granted")
                self.isGrantedNotificationAccess = true
            } else {
                print("Notification NOT Granted")
            }
            self.getNotificationSettings()
        }
        
        
        
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        if !launchedBefore {
            //set all UD to 0.0 aka current values
            let scoopStartTime = 0.0
            let cleanBoxStartTime = 0.0
            
            let defaults = UserDefaults.standard
            print("first launch, setting the four UserDefault variables to current value of 0.0")
            defaults.set(scoopStartTime, forKey: "sST")
            defaults.set(cleanBoxStartTime, forKey: "cBST")
            defaults.set(elapsedScoopTime, forKey: "eST")
            defaults.set(elapsedCleanBoxTime, forKey: "eCBT")
            defaults.synchronize()
        }
        else {
            loadDefaults()
        }
        
        print("eST on load = \(elapsedScoopTime)")
        print("eCBT on load = \(elapsedCleanBoxTime)")
        print("sST on load = \(scoopStartTime)")
        print("cBST on load = \(cleanBoxStartTime)")

        if elapsedCleanBoxTime > 0.0 || elapsedScoopTime > 0.0 {
            //start timers with current values and hide firstStartButton
            scoopTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateScoopTimer), userInfo: nil, repeats: true)
            cleanBoxTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateCleanBoxTimer), userInfo: nil, repeats: true)
            firstStartButton.isHidden = true
        }
        
        firstStartButton.isHidden = false
    }

    
    
    //MARK: press buttons
    @IBAction func firstStartButtonPressed(_ sender: Any) {
        scoopButtonPressed(UIButton.self)
        cleanBoxButtonPressed(UIButton.self)
        
        firstStartButton.isHidden = true
    }

    
    @IBAction func scoopButtonPressed(_ sender: Any) {
        scoopStartTime = NSDate.timeIntervalSinceReferenceDate
        
        print("sST = \(scoopStartTime)")
        
        let defaults = UserDefaults.standard
        defaults.set(scoopStartTime, forKey: "sST")
        defaults.synchronize()
        
        scoopTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateScoopTimer), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func cleanBoxButtonPressed(_ sender: Any) {
        cleanBoxStartTime = NSDate.timeIntervalSinceReferenceDate
        
        print("cBST = \(cleanBoxStartTime)")

        
        let defaults = UserDefaults.standard
        defaults.set(cleanBoxStartTime, forKey: "cBST")
        defaults.synchronize()
        
        cleanBoxTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(updateCleanBoxTimer), userInfo: nil, repeats: true)
        
        scoopButtonPressed(UIButton.self)
    }
    
    
    
    //MARK: updateTimers
    @objc func updateScoopTimer() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        elapsedScoopTime = currentTime - scoopStartTime
        
        
        //save
        let defaults = UserDefaults.standard
        defaults.set(elapsedScoopTime, forKey: "eST")
        defaults.synchronize()
        print("eST = \(elapsedScoopTime)")
        
        
        let days = Int(elapsedScoopTime / 86400)
        elapsedScoopTime -= (TimeInterval(days) * 86400)
        
        
        let hours = Int(elapsedScoopTime / 3600.0)
        elapsedScoopTime -= (TimeInterval(hours) * 3600)
        
        let minutes = Int(elapsedScoopTime / 60.0)
        elapsedScoopTime -= (TimeInterval(minutes) * 60)
        
        let seconds = Int(elapsedScoopTime)
        elapsedScoopTime -= TimeInterval(seconds)
        
        
        //update UIImage View based on time
        //if days >= 1 {
        if seconds >= 10 {
            print("RED LIGHT")
            imageView.image = UIImage(named: "redLight")
            
            sendRedNotification()
        }
        //else if hours >= 12 {
        else if seconds >= 3 {
            print("YELLOW LIGHT")
            imageView.image = UIImage(named: "yellowLight")
            
            sendYellowNotification()
        }
        else {
            imageView.image = UIImage(named: "greenLight")
        }
        
        
        let timeString = String(format:"%01i:%02i:%02i:%02i", days, hours, minutes, seconds)
        
        scoopLabel.text = timeString
    }
    
    
    @objc func updateCleanBoxTimer() {
        let currentTime2 = NSDate.timeIntervalSinceReferenceDate
        elapsedCleanBoxTime = currentTime2 - cleanBoxStartTime
        
        
        //save
        let defaults = UserDefaults.standard
        defaults.set(elapsedCleanBoxTime, forKey: "eCBT")
        defaults.synchronize()
        print("eCBT = \(elapsedCleanBoxTime)")
        
        
        let days2 = Int(elapsedCleanBoxTime / 86400)
        elapsedCleanBoxTime -= (TimeInterval(days2) * 86400)
        
        
//        let hours2 = Int(elapsedCleanBoxTime / 3600.0)
//        elapsedCleanBoxTime -= (TimeInterval(hours2) * 3600)
//
//        let minutes2 = Int(elapsedCleanBoxTime / 60.0)
//        elapsedCleanBoxTime -= (TimeInterval(minutes2) * 60)
//
//        let seconds2 = Int(elapsedCleanBoxTime)
//        elapsedCleanBoxTime -= TimeInterval(seconds2)
        
        let timeString = String(format:"%01i Days", days2)
        
        cleanBoxLabel.text = timeString
        cleanBoxLabel.sizeToFit()
    }
    
    func loadDefaults() {
        let defaults = UserDefaults.standard
        elapsedScoopTime = defaults.object(forKey: "eST") as! Double
        elapsedCleanBoxTime = defaults.object(forKey: "eCBT") as! Double
        if elapsedScoopTime > 0.0 || elapsedCleanBoxTime > 0.0 {
            scoopStartTime = defaults.object(forKey: "sST") as! TimeInterval
            cleanBoxStartTime = defaults.object(forKey: "cBST") as! TimeInterval
        }
    }
    
    
    //MARK: notification implementation
    func sendYellowNotification() {
        if isGrantedNotificationAccess {
            //add notification code here
            
            //set content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Yellow Light"
            content.subtitle = "From litterBoxStatus"
            content.body = "Notification after 3 seconds - Yellow Light"
            content.categoryIdentifier = "message"
            
            //set the trigger of the notification -- here a timer
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
            let trigger = UNNotificationTrigger()
            
            //set the request for the notiifcaiton from the above
            let request = UNNotificationRequest(identifier: "yellowLightMessage", content: content, trigger: trigger)
            
            //add the notification to the current notification center
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func sendRedNotification() {
    
    }

    //notificaiton app delegate (https://www.raywenderlich.com/156966/push-notifications-tutorial-getting-started)
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    
    
    
}

