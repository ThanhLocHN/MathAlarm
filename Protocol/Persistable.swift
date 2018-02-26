//
//  Persistable.swift
//  Alarm
//
//  Created by public on 1/4/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import Foundation

protocol Persistable{
    var ud: UserDefaults {get}
    var persistKey : String {get}
    func persist()
    func unpersist()
}
