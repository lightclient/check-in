//
//  EventViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/13/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class EventViewController: UITableViewController, UITextFieldDelegate {
    
    /* -------------------------------------------------------- */
    
    let firstGroup = [ ("Title"), ("Location") ]
    let secondGroup = [ ("Check-in attendees"), ("List of checked-in") ]
    let titleField = UITextField()
    let locationField = UITextField()
    
    let titleWheel = UIActivityIndicatorView()
    let locationWheel = UIActivityIndicatorView()
    
    var event: Event?
    
    var checkInPath : IndexPath?
    var checkAttendancePath : IndexPath?
    
    var saveButton = UIBarButtonItem()
    
    let TITLE_INDEX = 0
    let LOCATION_INDEX = 1
    
    /* -------------------------------------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdits))
        self.navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
        titleField.returnKeyType = .done
        locationField.returnKeyType = .done
        
        titleField.delegate = self
        locationField.delegate = self
        
        titleField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        locationField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        if let e = event {
            titleField.text = e.name
            locationField.text = e.location
            navigationItem.title = e.name
        } else {
            event = Event()
        }
    }
    
    func saveEdits() {
        
        if titleField.text != event?.name { titleWheel.startAnimating() }
        if locationField.text != event?.location { locationWheel.startAnimating() }
        
        event?.setName(n: titleField.text!)
        event?.setLocation(l: locationField.text!)
        event?.save {
            self.tableView.reloadData()
            self.navigationItem.title = self.event?.name
            self.titleWheel.stopAnimating()
            self.locationWheel.stopAnimating()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Event info"
        } else if section == 1 {
            return "Manage attendees"
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return firstGroup.count
        }
            
        else {
            return secondGroup.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        // Setup cell in the first group
        if indexPath.section == 0 {
            if(indexPath.row == TITLE_INDEX) {
                // Set up the title cell
                setupTextFieldInsideCell(textField: titleField, placeholder: "Title", cell: cell)
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                titleWheel.frame = frame
                titleWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(titleWheel)
                
                cell.selectionStyle = .none
                
            } else if indexPath.row == LOCATION_INDEX {
                // Set up the location cell
                setupTextFieldInsideCell(textField: locationField, placeholder: "Location", cell: cell)
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                locationWheel.frame = frame
                locationWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(locationWheel)
                
                cell.selectionStyle = .none
            }
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                cell.textLabel?.text = secondGroup[indexPath.row]
                cell.accessoryType = .disclosureIndicator
                checkInPath = indexPath
            } else if indexPath.row == 1 {
                cell.textLabel?.text = secondGroup[indexPath.row]
                cell.accessoryType = .disclosureIndicator
                checkAttendancePath = indexPath
            }

        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == checkInPath {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
            viewController.event = event
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            backItem.style = .done
            navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath == checkAttendancePath {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DirectoryViewController") as! DirectoryViewController
            viewController.event = event
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange() {
        if titleField.text != event?.name {
            saveButton.isEnabled = true
            return
        } else if locationField.text != event?.location {
            saveButton.isEnabled = true
            return
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func setupTextFieldInsideCell(textField: UITextField, placeholder: String, cell: UITableViewCell) {
        textField.frame = cell.frame
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(15), height: titleField.frame.size.height))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
        textField.placeholder = placeholder
        cell.addSubview(textField)
    }
    

}
