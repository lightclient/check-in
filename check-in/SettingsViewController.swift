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
    
    var passwordField = UITextField()
    var passwordField2 = UITextField()
    
    // Index paths to help find things
    var buttonIndexPath : IndexPath?
    
    // Event var that we will update w/ our new attendee
    var event = Event()
    
    // Activity wheels
    var nameWheel = UIActivityIndicatorView()
    var emailWheel = UIActivityIndicatorView()
    var passwordWheel = UIActivityIndicatorView()
    var passwordWheel2 = UIActivityIndicatorView()
    
    var transition = ElasticTransition()

    
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
        passwordField.delegate = self
        passwordField2.delegate = self
        
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField2.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        self.navigationItem.title = "Settings"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        transition.edge = .left
        
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic info"
        case 1:
            return "Change password"
        case 2:
            return "To be determined"
        default:
            return ""
        }
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
            }
            
            // Setup cells in second group
        } else  if indexPath.section == 1 {
            
            var textfield = passwordField
            var wheel = passwordWheel
            var placeholder = "Enter a new password"
            
            if indexPath.row == 1 { textfield = passwordField2; wheel = passwordWheel2; placeholder = "Re-enter new password" }
            
            // Place text field into cell & name cell
            setupTextFieldInsideCell(textField: textfield, placeholder: placeholder, cell: cell)
            cell.textLabel?.text = "Password"
            
            let frame = CGRect(x: cell.frame.maxX - 0, y: cell.frame.minY + 1, width: cell.frame.height, height: cell.frame.height)
            wheel.frame = frame
            wheel.activityIndicatorViewStyle = .gray
            cell.addSubview(wheel)
            
        } else if indexPath.section == 3 {
            
            // Save button
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .red //buttonColor
            buttonIndexPath = indexPath
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != buttonIndexPath { return }
        
        // initiate logout
        KCSUser.active().logout()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .custom
        self.transition.startingPoint = tableView.cellForRow(at: indexPath)?.center
        loginViewController.transitioningDelegate = self.transition
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.window?.rootViewController?.present(loginViewController, animated: true, completion: nil)
        
        self.showViewControllerWith(newViewController: loginViewController, usingAnimation: .ANIMATE_LEFT)
    }
    
    func saveEdits() {
        
        if nameField.text != user.name { nameWheel.startAnimating() }
        if emailField.text != user.email { emailWheel.startAnimating() }
        
        
        KCSUser.active().setValue(nameField.text, forKeyPath: "username")
        KCSUser.active().setValue(emailField.text, forKeyPath: "email")
        
        if (passwordField.text == passwordField2.text) && passwordField.text?.characters.count != 0 {
            
            passwordWheel.startAnimating()
            passwordWheel2.startAnimating()
            
            KCSUser.active().changePassword(passwordField.text, completionBlock: { (object, error) in
                print("\(error)")
                
                self.passwordWheel.stopAnimating()
                self.passwordWheel2.stopAnimating()
                
                self.passwordField.text = ""
                self.passwordField2.text = ""
                
                self.passwordField.placeholder = "Enter a new password"
                self.passwordField2.placeholder = "Re-enter new password"
                }
            )
        }
        
        
        KCSUser.active().save { (object, error) in
            print("\(error)")
            self.nameWheel.stopAnimating()
            self.emailWheel.stopAnimating()
        }
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
        } else if (passwordField.text == passwordField2.text) && passwordField.text?.characters.count != 0 {
            saveButton.isEnabled = true
            return
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        return true
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
    
    enum AnimationType{
        case ANIMATE_RIGHT
        case ANIMATE_LEFT
        case ANIMATE_UP
        case ANIMATE_DOWN
    }
    // Create Function...
    
    func showViewControllerWith(newViewController:UIViewController, usingAnimation animationType:AnimationType)
    {
        
        let currentViewController = UIApplication.shared.delegate?.window??.rootViewController
        let width = currentViewController?.view.frame.size.width;
        let height = currentViewController?.view.frame.size.height;
        
        var previousFrame:CGRect?
        var nextFrame:CGRect?
        
        switch animationType
        {
        case .ANIMATE_LEFT:
            previousFrame = CGRect(x: width!-1, y: 0.0, width: width!, height: height!)
            nextFrame = CGRect(x: -width!, y: 0.0, width: width!, height: height!);
        case .ANIMATE_RIGHT:
            previousFrame = CGRect(x: -width!+1, y: 0.0, width: width!, height: height!);
            nextFrame = CGRect(x: width!, y: 0.0, width: width!, height: height!);
        case .ANIMATE_UP:
            previousFrame = CGRect(x: 0.0, y: height!-1, width: width!, height: height!);
            nextFrame = CGRect(x: 0.0, y: -height!+1, width: width!, height: height!);
        case .ANIMATE_DOWN:
            previousFrame = CGRect(x: 0.0, y: -height!+1, width: width!, height: height!);
            nextFrame = CGRect(x: 0.0, y: height!-1, width: width!, height: height!);
        }
        
        newViewController.view.frame = previousFrame!
        UIApplication.shared.delegate?.window??.addSubview(newViewController.view)
        UIView.animate(withDuration: 0.33,
                                   animations: { () -> Void in
                                    newViewController.view.frame = (currentViewController?.view.frame)!
                                    currentViewController?.view.frame = nextFrame!
                                    
            })
        { (fihish:Bool) -> Void in
            UIApplication.shared.delegate?.window??.rootViewController = newViewController
        }
    }
    
}

