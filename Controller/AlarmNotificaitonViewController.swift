//
//  AlarmNotificaitonViewController.swift
//  Alarm
//
//  Created by public on 1/4/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit
import MediaPlayer

class AlarmNotificaitonViewController: UIViewController {

    /// Outlet
    @IBOutlet weak var resultBackgroundView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    
    /// Variable
    var isTrue: Bool = true
    
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    let alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var userInfo: [AnyHashable : Any]?
    
    //==> move to view model
    var isSnooze: Bool = false
    var soundName: String = ""
    var index: Int = -1
    
    /// Life cycle app
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userInfo = self.userInfo {
            isSnooze = userInfo["snooze"] as! Bool
            soundName = userInfo["soundName"] as! String
            index = userInfo["index"] as! Int
        }
        
        playAlarmSound()
        initBackGround()
        initQuestion()
    }
}

// MARK: - Init View
extension AlarmNotificaitonViewController {
    func initBackGround() {
        resultView.frame.size.width = 0
        reminderLabel.text = alarmModel.alarms[index].label
        
        self.view.backgroundColor = AlarmColor.pageBackgroundColor
        resultBackgroundView.layer.cornerRadius = 10
        resultView.layer.cornerRadius = 10
    }
    
    func initQuestion() {
        questionLabel.text = self.getQuestion().question
    }
    
    func playAlarmSound() {
        playSound(soundName)
        
        //Schedule notification for snooze
        if isSnooze {
            self.alarmScheduler.setNotificationForSnooze(snoozeMinute: 9, soundName: soundName, index: index)
        }
    }
}

// MARK: - Utilities function
extension AlarmNotificaitonViewController: AlarmApplicationDelegate {
    func getQuestion() -> (question: String, result: Bool){
        // Get random number
        let firstNumber: Int = Int(arc4random_uniform(30))
        let secondNumber: Int = Int(arc4random_uniform(30))
        let thirdNumber: Int = Int(arc4random_uniform(50))
        // Get random operator
        let operatorString: String = thirdNumber > 25 ? "+" : "-"
        
        let result: Bool = thirdNumber % 2 == 0
        self.isTrue = result
        var question: String = ""
        
        if result {
            let resultNumber: Int = operatorString == "+" ? firstNumber + secondNumber : firstNumber - secondNumber
            question = "\(firstNumber) \(operatorString) \(secondNumber) = \(resultNumber)"
        } else {
            question = "\(firstNumber) \(operatorString) \(secondNumber) = \(Int(arc4random_uniform(60)))"
        }
        
        return (question, result)
    }
    
    func turnOffAlarm() {
        let result = resultView.frame.size.width == resultBackgroundView.frame.size.width
        if result {
            // Turn off vibrate/ sound
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
            self.alarmModel.alarms[index].onSnooze = false
            
            // Change switch button state in main page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainAlarmViewController") as? MainAlarmViewController
            mainVC?.changeSwitchButtonState(index: index)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Play sound
    ///
    /// - Parameter soundName: Name of sound
    func playSound(_ soundName: String) {
        // Vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        // Set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                              nil,
                                              { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        },
                                              nil)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer?.delegate = AppDelegate()
            audioPlayer?.prepareToPlay()
        }
        
        // Negative number means loop infinity
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
    }
}

// MARK: - Action
extension AlarmNotificaitonViewController {
    @IBAction func trueButtonClicked(_ sender: Any) {
        if isTrue {
            resultView.frame.size.width += resultBackgroundView.frame.size.width / 3
        } else if !isTrue && resultView.frame.size.width != 0 {
            resultView.frame.size.width -= resultBackgroundView.frame.size.width / 3
        }
        questionLabel.text = self.getQuestion().question
        turnOffAlarm()
    }
    
    @IBAction func falseButtonClicked(_ sender: Any) {
        if !isTrue {
            resultView.frame.size.width += resultBackgroundView.frame.size.width / 3
        } else if isTrue && resultView.frame.size.width != 0 {
            resultView.frame.size.width -= resultBackgroundView.frame.size.width / 3
        }
        questionLabel.text = self.getQuestion().question
        turnOffAlarm()
    }
}
