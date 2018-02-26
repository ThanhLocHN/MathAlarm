//
//  MainAlarmViewController.swift
//  Alarm
//
//  Created by public on 1/6/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit

extension UIViewController {
    func setupNavigationBar() {
        let titleAttributes = [NSAttributedStringKey.foregroundColor: AlarmColor.labelWhiteColor]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.barTintColor = AlarmColor.pageBackgroundColor
    }
    
    func setupBackGroup() {
        self.view.backgroundColor = AlarmColor.pageBackgroundColor
    }
    
    func setupTableView(_ tableView: UITableView) {
        tableView.backgroundColor = AlarmColor.pageBackgroundColor
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.separatorInset.left = 0
    }
    
    func setupView(tableview: UITableView) {
        setupNavigationBar()
        setupBackGroup()
        setupTableView(tableview)
    }
}

class MainAlarmViewController: UITableViewController{
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initColor()
        setupView(tableview: self.tableView)
        alarmScheduler.checkNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarmModel = Alarms()
        setupNavigationBar()
        tableView.reloadData()
    }
}

// MARK: - Init view
extension MainAlarmViewController {
    private func initColor() {
        self.tableView.backgroundColor = AlarmColor.pageBackgroundColor

        self.view.backgroundColor = AlarmColor.pageBackgroundColor
        self.tableView.backgroundColor = AlarmColor.pageBackgroundColor
        
        let titleAttributes = [NSAttributedStringKey.foregroundColor: AlarmColor.labelWhiteColor]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.barTintColor = AlarmColor.pageBackgroundColor
    }
}

// MARK: - Utilities
extension MainAlarmViewController {
    func changeSwitchButtonState(index: Int) {
        alarmModel = Alarms()
        if alarmModel.alarms[index].repeatWeekdays.isEmpty {
            alarmModel.alarms[index].enabled = false
        }
        let cells = tableView.visibleCells
        for cell in cells {
            if cell.tag == index {
                let sw = cell.accessoryView as! UISwitch
                if alarmModel.alarms[index].repeatWeekdays.isEmpty {
                    sw.setOn(false, animated: false)
                    cell.textLabel?.alpha = 0.5
                    cell.detailTextLabel?.alpha = 0.5
                }
            }
        }
    }
}

// MARK: - Segue
extension MainAlarmViewController {
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let dist = segue.destination as! UINavigationController
        let addEditController = dist.topViewController as! AlarmAddEditViewController
        if segue.identifier == Id.addSegueIdentifier {
            addEditController.navigationItem.title = "Add Alarm"
            addEditController.segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, reminderLabel: "Alarm", mediaLabel: "bell", mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false)
        }
        else if segue.identifier == Id.editSegueIdentifier {
            addEditController.navigationItem.title = "Edit Alarm"
            addEditController.segueInfo = sender as! SegueInfo
            addEditController.datePicker?.date = alarmModel.alarms[addEditController.segueInfo.curCellIndex].date
        }
    }
}

// MARK: - Action
extension MainAlarmViewController {
    @IBAction func unwindFromAddEditAlarmView(_ segue: UIStoryboardSegue) {
        isEditing = false
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        alarmModel.alarms[index].enabled = sender.isOn
        if sender.isOn {
            alarmScheduler.setNotificationWithDate(alarmModel.alarms[index].date, onWeekdaysForNotify: alarmModel.alarms[index].repeatWeekdays, snoozeEnabled: alarmModel.alarms[index].snoozeEnabled, onSnooze: false, soundName: alarmModel.alarms[index].mediaLabel, index: index)
            tableView.reloadData()
        }
        else {
            alarmScheduler.reSchedule()
            tableView.reloadData()
        }
    }
}

// MARK: - Table view data source
extension MainAlarmViewController {
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            alarmModel.alarms.remove(at: index)
            let cells = tableView.visibleCells
            for cell in cells {
                let sw = cell.accessoryView as! UISwitch
                // Adjust saved index when row deleted
                if sw.tag > index {
                    sw.tag -= 1
                }
            }
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            alarmScheduler.reSchedule()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmModel.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Id.editSegueIdentifier, sender: SegueInfo(curCellIndex: indexPath.row, isEditMode: true, reminderLabel: alarmModel.alarms[indexPath.row].label, mediaLabel: alarmModel.alarms[indexPath.row].mediaLabel, mediaID: alarmModel.alarms[indexPath.row].mediaID, repeatWeekdays: alarmModel.alarms[indexPath.row].repeatWeekdays, enabled: alarmModel.alarms[indexPath.row].enabled, snoozeEnabled: alarmModel.alarms[indexPath.row].snoozeEnabled))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.alarmCellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Id.alarmCellIdentifier)
        }
        
        // Cell text
        cell!.selectionStyle = .none
        cell!.tag = indexPath.row
        let alarm: Alarm = alarmModel.alarms[indexPath.row]
        let amAttr: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20.0)]
        let str = NSMutableAttributedString(string: alarm.formattedTime, attributes: amAttr)
        let timeAttr: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 45.0)]
        str.addAttributes(timeAttr, range: NSMakeRange(0, str.length-2))
        cell!.textLabel?.attributedText = str
        cell!.detailTextLabel?.text = alarm.label
        
        // Append switch button
        let sw = UISwitch(frame: CGRect())
        sw.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);
        
        // Text color
        cell?.detailTextLabel?.textColor = AlarmColor.labelWhiteColor
        cell?.textLabel?.textColor = AlarmColor.labelWhiteColor
        
        // Tag is used to indicate which row had been touched
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(MainAlarmViewController.switchTapped(_:)), for: UIControlEvents.valueChanged)
        if alarm.enabled {
            cell!.backgroundColor = AlarmColor.tableSelectedCellBackgroundColor
            cell!.textLabel?.alpha = 1.0
            cell!.detailTextLabel?.alpha = 1.0
            sw.setOn(true, animated: false)
        } else {
            cell!.backgroundColor = AlarmColor.tableCellBackgroundColor
            cell!.textLabel?.alpha = 0.5
            cell!.detailTextLabel?.alpha = 0.5
        }
        cell!.accessoryView = sw
        
        return cell!
    }
}
