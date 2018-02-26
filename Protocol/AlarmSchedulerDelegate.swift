//
//  AlarmSchedulerDelegate.swift
//  Alarm
//
//  Created by public on 1/4/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import Foundation

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(_ date: Date, onWeekdaysForNotify:[Int], snoozeEnabled: Bool, onSnooze:Bool, soundName: String, index: Int)
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setupNotificationSettings()
    func reSchedule()
    func checkNotification()
}
