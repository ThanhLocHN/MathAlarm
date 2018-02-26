//
//  SoundViewController.swift
//  Alarm
//
//  Created by apple on 1/17/18.
//  Copyright © 2018 ThanhLoc. All rights reserved.
//

import UIKit
import MediaPlayer

class SoundViewController: UIViewController {

    /// Outlet
    @IBOutlet weak var tableView: UITableView!
    
    /// Variable
    fileprivate let numberOfRingtones = 2
    var mediaItem: MPMediaItem?
    var mediaLabel: String!
    var mediaID: String!
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(tableview: self.tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        performSegue(withIdentifier: Id.soundUnwindIdentifier, sender: self)
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - MPMediaPicker controller delegate
extension SoundViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItemCollection:MPMediaItemCollection) -> Void {
        if !mediaItemCollection.items.isEmpty {
            let aMediaItem = mediaItemCollection.items[0]
            
            self.mediaItem = aMediaItem
            mediaID = (self.mediaItem?.value(forProperty: MPMediaItemPropertyPersistentID)) as! String
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view data source/ delegate
extension SoundViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerVw = UIView.init(frame:  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 24))
        footerVw.backgroundColor = AlarmColor.pageBackgroundColor
        return footerVw
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
        header.backgroundColor = UIColor.black
        header.roundTopCorners()
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return numberOfRingtones
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "VIBRATION"
        } else if section == 1 {
            return "SONGS"
        } else {
            return "RINGTONS"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.musicIdentifier)
        
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: Id.musicIdentifier)
        }
        if indexPath.section == 0 {
            cell!.textLabel!.text = "Vibration"
            cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Pick a song"
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Bell"
            } else if indexPath.row == 1 {
                cell!.textLabel!.text = "Tickle"
            }
            
            if cell!.textLabel!.text == mediaLabel {
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        
        cell?.backgroundColor = AlarmColor.tableSelectedCellBackgroundColor
        cell?.textLabel?.textColor = AlarmColor.labelWhiteColor
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Select any song!"
        mediaPicker.allowsPickingMultipleItems = false
        
        if indexPath.section == 1 {
            self.present(mediaPicker, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            mediaLabel = cell?.textLabel?.text!
            cell?.setSelected(true, animated: true)
            cell?.setSelected(false, animated: true)
            let cells = tableView.visibleCells
            for cellItem in cells {
                let section = tableView.indexPath(for: cellItem)?.section
                if (section == indexPath.section && cellItem != cell) {
                    cellItem.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        }
    }
}
