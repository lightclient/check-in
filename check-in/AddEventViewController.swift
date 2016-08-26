//
//  AddEventViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/13/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class AddEventViewController: UITableViewController, UITextFieldDelegate {
    
    let firstGroup = [ ("Title"), ("Location") ]
    let secondGroup = [ ("Starts"), ("startPicker"), ("Ends"), ("endPicker") ]
    let titleField = UITextField()
    let locationField = UITextField()
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    var startDateIndexPath = IndexPath()
    var endDateIndexPath = IndexPath()

    let TITLE_INDEX = 0
    let LOCATION_INDEX = 1
    
    @IBAction func submitAddNewEvent(_ sender: AnyObject) {
        addNewEvent(name: titleField.text!, startDate: startDatePicker.date, endDate: endDatePicker.date, location: locationField.text!, id: KCSUser.active().getValueForAttribute("groupIdentifier") as! String)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAddEvent(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        
        var cell = UITableViewCell()
        
        // Setup cell in the first group
        if indexPath.section == 0 {
            
            
            if(indexPath.row == TITLE_INDEX) {
                // Set up the title cell
                setupTextFieldInsideCell(textField: titleField, placeholder: "Title", cell: cell)
            } else if indexPath.row == LOCATION_INDEX {
                // Set up the location cell
                setupTextFieldInsideCell(textField: locationField, placeholder: "Location", cell: cell)
            }
        } else {
            
            if(secondGroup[indexPath.row] == "startPicker") {
                startDatePicker.addTarget(self, action: #selector(AddEventViewController.startDatePickerValueChanged), for: .valueChanged)
                cell.addSubview(startDatePicker)
            } else if secondGroup[indexPath.row] == "endPicker" {
                endDatePicker.addTarget(self, action: #selector(AddEventViewController.endDatePickerValueChanged), for: .valueChanged)
                cell.addSubview(endDatePicker)
            } else if secondGroup[indexPath.row] == "Starts" {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                startDateIndexPath = indexPath
                cell.textLabel?.text = secondGroup[indexPath.row]
            } else if secondGroup[indexPath.row] == "Ends" {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                endDateIndexPath = indexPath
                cell.textLabel?.text = secondGroup[indexPath.row]
            }
        }
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = UITableViewCell()
    }*/
    
   /* func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == titleField) {
            self.tableView(tableView, cellForRowAt: IndexPath(index: TITLE_INDEX)).textLabel?.text = textField.text
        } else if(textField == titleField) {
            self.tableView(tableView, cellForRowAt: IndexPath(index: LOCATION_INDEX)).textLabel?.text = textField.text
        }
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 1 && indexPath.row == 3) {
            return 210
        }
        return 44
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
    
    func startDatePickerValueChanged() {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: startDatePicker.date)
        tableView.cellForRow(at: startDateIndexPath)?.detailTextLabel?.text = strDate
    }
    
    func endDatePickerValueChanged() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: endDatePicker.date)
        tableView.cellForRow(at: endDateIndexPath)?.detailTextLabel?.text = strDate
    }
    
    func addNewEvent(name: String, startDate: NSDate, endDate: NSDate, location: String, id: String) {
        let event = Event()
        event.setAll(_entityId: KCSEntityKeyId.dynamicType.init(), _name: name, _startDate: startDate, _endDate: endDate, _location: location, _attendees: [], _groupIdentifer: id, _metadata: KCSMetadata.init())
        event.save {
            //
        }
    }

    

}
