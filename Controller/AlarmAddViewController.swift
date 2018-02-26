//
//  AlarmAddViewController.swift
//  Alarm
//
//  Created by public on 1/6/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer

class AlarmAddEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate{
    
    /// Outlet
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    /// Variable
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    var enabled: Bool!
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(tableview: self.tableView)
        datePicker.setValue(UIColor.white, forKey: "textColor")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmModel = Alarms()
        tableView.reloadData()
        snoozeEnabled = segueInfo.snoozeEnabled
        super.viewWillAppear(animated)
    }
}

// MARK: - Utilities function
extension AlarmAddEditViewController {
    func editReminder() {
        let alert = UIAlertController(title: "Reminder", message: "Edit text of reminder then choose SAVE if you want, otherwise choose CANCEL", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Input text in here"
            textField.returnKeyType = UIReturnKeyType.default
        }
        let saveAction = UIAlertAction(title: "Save", style: .cancel) { (action) in
            if let textFields = alert.textFields, !textFields.isEmpty {
                var inputText = textFields[0].text ?? "Alarm"
                inputText = inputText == "" ? "Alarm" : inputText
                self.segueInfo.reminderLabel = inputText
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in

        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
//        let reminderPopoverVC = ReminderPopoverViewController(nibName: "ReminderPopoverViewController", bundle: nil)
//        reminderPopoverVC.saveButtonClickedCallBack = {
//            var inputText = reminderPopoverVC.textField.text ?? "Alarm"
//            inputText = inputText == "" ? "Alarm" : inputText
//            self.segueInfo.reminderLabel = inputText
//            self.tableView.reloadData()
//        }
//
//        reminderPopoverVC.modalPresentationStyle = .formSheet
//        reminderPopoverVC.preferredContentSize = CGSize(width: 100, height: 200)
//        reminderPopoverVC.popoverPresentationController?.delegate = self
//        reminderPopoverVC.popoverPresentationController?.sourceView = self.view
//        reminderPopoverVC.popoverPresentationController?.sourceRect = CGRect(x: 300, y: 40, width: 0, height: 0)
//        self.present(reminderPopoverVC, animated: true, completion: nil)
    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
}

// MARK: - Navigation
extension AlarmAddEditViewController {
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Id.saveSegueIdentifier {
            let dist = segue.destination as! MainAlarmViewController
            let cells = dist.tableView.visibleCells
            for cell in cells {
                let sw = cell.accessoryView as! UISwitch
                if sw.tag > segueInfo.curCellIndex
                {
                    sw.tag -= 1
                }
            }
            alarmScheduler.reSchedule()
        } else if segue.identifier == Id.soundSegueIdentifier {
            let dist = segue.destination as! SoundViewController
            dist.mediaID = segueInfo.mediaID
            dist.mediaLabel = segueInfo.mediaLabel
        } else if segue.identifier == Id.weekdaysSegueIdentifier {
            let dist = segue.destination as! WeekdaysViewController
            dist.weekdays = segueInfo.repeatWeekdays
        }
    }
}

// MARK: - Action
extension AlarmAddEditViewController {
    @IBAction func saveEditAlarm(_ sender: AnyObject) {
        let date = Scheduler.correctSecondComponent(date: datePicker.date)
        let index = segueInfo.curCellIndex
        var tempAlarm = Alarm()
        tempAlarm.date = date
        tempAlarm.label = segueInfo.reminderLabel
        tempAlarm.enabled = true
        tempAlarm.mediaLabel = segueInfo.mediaLabel
        tempAlarm.mediaID = segueInfo.mediaID
        tempAlarm.snoozeEnabled = snoozeEnabled
        tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
        tempAlarm.uuid = UUID().uuidString
        tempAlarm.onSnooze = false
        if segueInfo.isEditMode {
            alarmModel.alarms[index] = tempAlarm
        }
        else {
            alarmModel.alarms.append(tempAlarm)
        }
        self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
    }
    
    @IBAction func snoozeSwitchTapped (_ sender: UISwitch) {
        snoozeEnabled = sender.isOn
    }
    
    @IBAction func unwindFromWeekdaysView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! WeekdaysViewController
        segueInfo.repeatWeekdays = src.weekdays
    }
    
    @IBAction func unwindFromMediaView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! SoundViewController
        segueInfo.mediaLabel = src.mediaLabel
        segueInfo.mediaID = src.mediaID
    }
}

// MARK: - Table view data source/ delegate
extension AlarmAddEditViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        if segueInfo.isEditMode {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.settingIdentifier)

        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: Id.settingIdentifier)
            cell?.textLabel?.textColor = AlarmColor.labelWhiteColor
        }
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                cell!.textLabel!.text = "Repeat"
                cell!.detailTextLabel!.text = WeekdaysViewController.repeatText(weekdays: segueInfo.repeatWeekdays)
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 1 {
                cell!.textLabel!.text = "Reminder"
                cell!.detailTextLabel!.text = segueInfo.reminderLabel
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 2 {
                cell!.textLabel!.text = "Sound"
                cell!.detailTextLabel!.text = segueInfo.mediaLabel
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 3 {
                
                cell!.textLabel!.text = "Snooze"
                let sw = UISwitch(frame: CGRect())
                sw.addTarget(self, action: #selector(AlarmAddEditViewController.snoozeSwitchTapped(_:)), for: UIControlEvents.touchUpInside)
                
                if snoozeEnabled {
                    sw.setOn(true, animated: false)
                }
                
                cell!.accessoryView = sw
            }
        }
        else if indexPath.section == 1 {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: Id.settingIdentifier)
            cell!.textLabel!.text = "Delete Alarm"
            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.textColor = AlarmColor.labelRedColor
        }
        cell?.backgroundColor = AlarmColor.tableCellBackgroundColor
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: Id.weekdaysSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 1:
                editReminder()
                cell?.setSelected(true, animated: true)
                cell?.setSelected(false, animated: true)
            case 2:
                performSegue(withIdentifier: Id.soundSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            // Delete alarm
            alarmModel.alarms.remove(at: segueInfo.curCellIndex)
            performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
        }
    }
}
