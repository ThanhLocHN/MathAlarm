//
//  ReminderPopoverViewController.swift
//  Alarm
//
//  Created by public on 1/9/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit

class ReminderPopoverViewController: UIViewController {

    /// Outlet
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    /// Variable
    var saveButtonClickedCallBack: (() -> Void)?
    var cancelButtonClickedCallBack: (() -> Void)?
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubviews()
    }
}

// MARK: - Init view
extension ReminderPopoverViewController {
    func initSubviews() {
        initBacground()
        initTextField()
        initBounds()
        initButton()
    }
    
    func initBacground() {
        self.view.backgroundColor = AlarmColor.pageBackgroundColor
    }
    
    func initTextField() {
        textField.backgroundColor = AlarmColor.pageBackgroundColor
        textField.textColor = AlarmColor.labelWhiteColor
    }
    
    func initBounds() {
        self.preferredContentSize = CGSize(width: 100, height: 200)
        self.view.layer.cornerRadius = 4
    }
    
    func initButton() {
        saveButton.backgroundColor = UIColor.clear
        saveButton.layer.cornerRadius = 4
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.black.cgColor
        saveButton.setTitle("Save", for: .selected)
        
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.layer.cornerRadius = 4
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.setTitle("Cancel", for: .normal)
    }
}

// MARK: - Action
extension ReminderPopoverViewController {
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.saveButtonClickedCallBack?()
        self.dismiss(animated: true, completion: nil)
    }
}
