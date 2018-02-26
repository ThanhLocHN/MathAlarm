//
//  WeekdaysViewController.swift
//  Alarm
//
//  Created by public on 1/6/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit

class WeekdaysViewController: UITableViewController {
    
    /// Variable
    var weekdays: [Int]!
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(tableview: self.tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        performSegue(withIdentifier: Id.weekdaysUnwindIdentifier, sender: self)
    }
}

// MARK: - Init view
extension WeekdaysViewController {
    func setupBackGround() {
        self.view.backgroundColor = AlarmColor.pageBackgroundColor
    }
    
    func setupTableView() {
        tableView.backgroundColor = AlarmColor.pageBackgroundColor
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
}

// MARK: - TableView datasource, tableview delegate
extension WeekdaysViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = AlarmColor.tableSelectedCellBackgroundColor
        cell.textLabel?.textColor = AlarmColor.labelWhiteColor
        
        for weekday in weekdays
        {
            if weekday == (indexPath.row + 1) {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if let index = weekdays.index(of: (indexPath.row + 1)){
            weekdays.remove(at: index)
            cell.setSelected(true, animated: true)
            cell.setSelected(false, animated: true)
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.backgroundColor = AlarmColor.tableCellBackgroundColor
        }
        else{
            // Row index start from 0, weekdays index start from 1 (Sunday), so plus 1
            weekdays.append(indexPath.row + 1)
            cell.setSelected(true, animated: true)
            cell.setSelected(false, animated: true)
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.backgroundColor = AlarmColor.tableSelectedCellBackgroundColor
            
        }
    }
}

// MARK: - Utilities function
extension WeekdaysViewController {
    static func repeatText(weekdays: [Int]) -> String {
        if weekdays.count == 7 {
            return "Every day"
        }
        
        if weekdays.isEmpty {
            return "Never"
        }
        
        var ret = String()
        var weekdaysSorted:[Int] = [Int]()
        
        weekdaysSorted = weekdays.sorted(by: <)
        
        for day in weekdaysSorted {
            switch day{
            case 1:
                ret += "Sun "
            case 2:
                ret += "Mon "
            case 3:
                ret += "Tue "
            case 4:
                ret += "Wed "
            case 5:
                ret += "Thu "
            case 6:
                ret += "Fri "
            case 7:
                ret += "Sat "
            default:
                break
            }
        }
        return ret
    }
}

