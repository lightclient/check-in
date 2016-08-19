//
//  SecondViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    // Declare text fields that will be embedded into cells
    var nameField = UITextField()
    var emailField = UITextField()
    var idField = UITextField()
    
    // Index paths to help find things
    var idIndexPath : IndexPath?
    var buttonIndexPath : IndexPath?
    
    // Event var that we will update w/ our new attendee
    var event = Event()
    
    // Activity wheels
    var nameWheel = UIActivityIndicatorView()
    var emailWheel = UIActivityIndicatorView()
    var idWheel = UIActivityIndicatorView()
    var saveWheel = UIActivityIndicatorView()
    
    var saveButton = UIBarButtonItem()
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdits))
        self.navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
        nameField.returnKeyType = .done
        emailField.returnKeyType = .done
        idField.returnKeyType = .done
        
        // Set delegates for the text fields
        nameField.delegate = self
        emailField.delegate = self
        idField.delegate = self
        
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        idField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        self.navigationItem.title = "Settings"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        loadUserData()
        
        print("Settings loaded")
    }

    @IBAction func buttonPressed(_ sender: AnyObject) {
        KCSUser.active().logout()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(viewController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()//tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        // Setup cells in the first group
        if indexPath.section == 0 {
            
            // First cell
            if(indexPath.row == 0) {
                
                // Place text field into cell & name cell
                setupTextFieldInsideCell(textField: nameField, placeholder: "Username", cell: cell)
                cell.textLabel?.text = "Username"
                
                let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
                nameWheel.frame = frame
                nameWheel.activityIndicatorViewStyle = .gray
                cell.addSubview(nameWheel)
                
                // Populate cell (if possible), otherwise put in placeholder text
                if user.name != nil {
                    nameField.text = user.name
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
                if user.email != nil {
                    emailField.text = user.email
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
                if user.id != nil {
                    idField.text = user.id
                } else {
                    idField.text = ""
                    idField.placeholder = "Enter ID"
                }
            }
            
            // Setup cells in second group
        } else {
            
        }
        
        return cell
    }
    
    func saveEdits() {
        
        //if titleField.text != event?.name { titleWheel.startAnimating() }
        //if locationField.text != event?.location { locationWheel.startAnimating() }
        //KCSUser.active().setValue(nameField.text, forKeyPath: "username")
        KCSUser.active().setValue(emailField.text, forKeyPath: "email")
        KCSUser.active().save(completionBlock: nil)
    }
    
    func loadUserData() {
        user.name = KCSUser.active().username
        user.email = KCSUser.active().email
        user.id = "390123"
        
        tableView.reloadData()
    }
    
    func textFieldDidChange() {
        if nameField.text != user.name {
            saveButton.isEnabled = true
            return
        } else if emailField.text != user.email {
            saveButton.isEnabled = true
            return
        }  else if idField.text != user.id {
            saveButton.isEnabled = true
            return
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // Hide keyboard if tapped away from keyboard and textfields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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

