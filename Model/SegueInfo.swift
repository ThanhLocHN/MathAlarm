//
//  SegueInfo.swift
//  Alarm
//
//  Created by public on 1/4/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import Foundation

struct SegueInfo {
    var curCellIndex: Int
    var isEditMode: Bool
    var reminderLabel: String
    var mediaLabel: String
    var mediaID: String
    var repeatWeekdays: [Int]
    var enabled: Bool
    var snoozeEnabled: Bool
}
