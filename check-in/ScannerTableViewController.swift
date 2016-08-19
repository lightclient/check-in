//
//  ScannerTableViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/14/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

protocol ScannerTableViewDelegate: class {
    func readyToCaptureAgain()
}

let DEFUALT_BUTTON_TEXT = "Complete check-in"
let NEW_MEMBER_SAVE_TEXT = "Create new member and check-in"

class ScannerTableViewController: UITableViewController, UITextFieldDelegate {
    
    /* -------------------------------------------------------- */
    
    weak var delegate:ScannerTableViewDelegate?
    
    // Declare text fields that will be embedded into cells
    var nameField = UITextField()
    var emailField = UITextField()
    var idField = UITextField()

    // Index paths to help find things
    var idIndexPath : IndexPath?
    var buttonIndexPath : IndexPath?
    
    // Member var that we will submit to backend
    var member = Member()
    
    // Event var that we will update w/ our new attendee
    var event = Event()
    
    // Activity wheels
    var nameWheel = UIActivityIndicatorView()
    var emailWheel = UIActivityIndicatorView()
    var idWheel = UIActivityIndicatorView()
    var saveWheel = UIActivityIndicatorView()
    
    // Var to update button text
    var buttonText = DEFUALT_BUTTON_TEXT
    
    /* -------------------------------------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.returnKeyType = .done
        emailField.returnKeyType = .done
        idField.returnKeyType = .done
        
        // Set delegates for the text fields
        nameField.delegate = self
        emailField.delegate = self
        idField.delegate = self
    }
    
    // Load the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        // Setup cells in the first group
        if indexPath.section == 0 {
            
            // First cell
            if(indexPath.row == 0) {
                
                // Place text field into cell & name cell
                setupTextFieldInsideCell(textField: nameField, placeholder: "Name", cell: cell)
                cell.textLabel?.text = "Name"
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                nameWheel.frame = frame
                nameWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(nameWheel)
                
                // Populate cell (if possible), otherwise put in placeholder text
                if member.name != nil {
                    nameField.text = member.name
                } else {
                    nameField.text = ""
                    nameField.placeholder = "Enter name"
                }
              
              // Second cell
            } else if indexPath.row == 1 {
                
                // Place text field into cell & name cell
                setupTextFieldInsideCell(textField: emailField, placeholder: "Email", cell: cell)
                cell.textLabel?.text = "Email"
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                emailWheel.frame = frame
                emailWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(emailWheel)
                
                // Populate cell (if possible), otherwise put in placeholder text
                if member.email != nil {
                    emailField.text = member.email
                } else {
                    emailField.text = ""
                    emailField.placeholder = "Enter email"
                }
                
              // Third cell
            } else if indexPath.row == 2 {
                
                // Place text field into cell & name cell
                setupTextFieldInsideCell(textField: idField, placeholder: "ID", cell: cell)
                cell.textLabel?.text = "ID Number"
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                idWheel.frame = frame
                idWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(idWheel)
                
                // Set indexPath to find later easily
                idIndexPath = indexPath
                
                // Populate cell (if possible), otherwise put in placeholder text
                if member.id != nil {
                    idField.text = member.id
                } else {
                    idField.text = ""
                    idField.placeholder = "Enter ID"
                }
            }
            
          // Setup cells in second group
        } else {
                // Save button
                cell.textLabel?.text = buttonText
                cell.textLabel?.textColor = .red //buttonColor
                buttonIndexPath = indexPath
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                saveWheel.frame = frame
                saveWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(saveWheel)
            
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Don't care about rows that aren't the button row
        if indexPath != buttonIndexPath { return }
        
        self.saveWheel.startAnimating()
        
        // Update member var w/ user inputted info        
        member.setName(n: nameField.text!)
        member.setEmail(e: emailField.text!)
        member.setId(i: idField.text!)
        _ = member.addEvent(e: event)
        member.setGroupIdentifier(g: event.groupIdentifier!)
        
        // Save changes
        member.save {
            let m = self.member
            self.loadTextFields(m: Member())
            self.delegate?.readyToCaptureAgain()
            self.updateEventWithNewAttendee(m: m)
        }
    }
    
    // Adds the attendee to the even (if the attendee is not already added)
    func updateEventWithNewAttendee(m: Member) {
        
        // Add the member's entityId to the event
        if(!event.addAttendee(m: m)) { self.saveWheel.stopAnimating(); return }
        
        // Save the event
        event.save {
            self.saveWheel.stopAnimating()
        }
    }
    
    // Search database for id, reload textfields with info
    func didCaptureBarcode(barcode: String) {
        member.loadFromID(id: barcode, groupID: event.groupIdentifier!, completion: { (success: Bool) -> Void in
            if success {
                // Populate member w/ data from database
                self.buttonText = DEFUALT_BUTTON_TEXT
                self.loadTextFields(m: self.member)
            } else {
                self.member.setId(i: barcode)
                self.buttonText = NEW_MEMBER_SAVE_TEXT
                self.loadTextFields(m: self.member)
            }
            
            self.nameWheel.stopAnimating()
            self.emailWheel.stopAnimating()
            self.idWheel.stopAnimating()
        })
    }
    
    func loadTextFields(m: Member) {
        member = m
        tableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupTextFieldInsideCell(textField: UITextField, placeholder: String, cell: UITableViewCell) {
        let frame = CGRect(x: cell.frame.minX, y: cell.frame.minY + 1, width: cell.frame.width, height: cell.frame.height)
        textField.frame = frame
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(115), height: nameField.frame.size.height))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
        textField.placeholder = placeholder
        cell.addSubview(textField)
    }
}

