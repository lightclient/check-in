//
//  MemberViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/20/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class MemberViewController: UITableViewController, UITextFieldDelegate {

    var member : Member?
    
    
    let firstGroup = [ ("Name"), ("Email"), ("ID") ]
    let secondGroup = [ ("Check-in attendees"), ("List of checked-in") ]
    
    let nameField = UITextField()
    let emailField = UITextField()
    let idField = UITextField()
    
    let nameWheel = UIActivityIndicatorView()
    let emailWheel = UIActivityIndicatorView()
    let idWheel = UIActivityIndicatorView()
    
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
        
        nameField.returnKeyType = .done
        emailField.returnKeyType = .done
        idField.returnKeyType = .done
        
        nameField.delegate = self
        emailField.delegate = self
        idField.delegate = self
        
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        idField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        if let m = member {
            nameField.text = m.name
            emailField.text = m.email
            idField.text = m.id
            navigationItem.title = m.name
        } else {
            member = Member()
        }
    }
    
    func saveEdits() {
        
        if nameField.text != member?.name { nameWheel.startAnimating() }
        if emailField.text != member?.email { emailWheel.startAnimating() }
        if idField.text != member?.id { idWheel.startAnimating() }
        
        member?.setName(n: nameField.text!)
        member?.setEmail(e: emailField.text!)
        member?.save {
            self.tableView.reloadData()
            self.navigationItem.title = self.member?.name
            self.nameWheel.stopAnimating()
            self.emailWheel.stopAnimating()
            self.idWheel.stopAnimating()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Member info"
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
            if(indexPath.row == 0) {
                // Set up the title cell
                setupTextFieldInsideCell(textField: nameField, placeholder: "Name", cell: cell)
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                nameWheel.frame = frame
                nameWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(nameWheel)
                
                cell.selectionStyle = .none
                
            } else if indexPath.row == 1 {
                // Set up the location cell
                setupTextFieldInsideCell(textField: emailField, placeholder: "Email", cell: cell)
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                emailWheel.frame = frame
                emailWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(emailWheel)
                
                cell.selectionStyle = .none
            } else if indexPath.row == 2 {
                setupTextFieldInsideCell(textField: idField, placeholder: "ID", cell: cell)
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                emailWheel.frame = frame
                emailWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(idWheel)
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
       /* if indexPath == checkInPath {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
            viewController.event = event
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            backItem.style = .done
            navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }*/
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
        if nameField.text != member?.name {
            saveButton.isEnabled = true
            return
        } else if emailField.text != member?.email {
            saveButton.isEnabled = true
            return
        } else if idField.text != member?.id {
            saveButton.isEnabled = true
            return
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func setupTextFieldInsideCell(textField: UITextField, placeholder: String, cell: UITableViewCell) {
        textField.frame = cell.frame
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(15), height: textField.frame.size.height))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
        textField.placeholder = placeholder
        cell.addSubview(textField)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
