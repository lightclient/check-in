//
//  SignupViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/13/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: ElasticModalViewController, UITextFieldDelegate {
    
    /* -------------------------------------------------------- */
    
    let opaqueColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.2)
    
    let usernameWheel = UIActivityIndicatorView()
    let emailWheel = UIActivityIndicatorView()
    let passwordWheel = UIActivityIndicatorView()
    let groupIdWheel = UIActivityIndicatorView()

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var groupIdField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    /* -------------------------------------------------------- */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create target to be called when the text fields are changed (to determine if the input is valid)
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        groupIdField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        groupIdField.delegate = self
        
        // Make the textfields look pretty
        setUpTextField(imageNamed: "user.png", placeholder: "Username", textfield: usernameField)
        setUpTextField(imageNamed: "lock.png", placeholder: "Password", textfield: passwordField)
        setUpTextField(imageNamed: "email.png", placeholder: "Email", textfield: emailField)
        setUpTextField(imageNamed: "groupID.png", placeholder: "Group Identifier", textfield: groupIdField)
        
        // Embed the activity wheels into the right area in the textfields
        setUpActivityWheel(activityWheel: usernameWheel, textfield: usernameField)
        setUpActivityWheel(activityWheel: passwordWheel, textfield: passwordField)
        setUpActivityWheel(activityWheel: emailWheel, textfield: emailField)
        setUpActivityWheel(activityWheel: groupIdWheel, textfield: groupIdField)
        
        // Make the sign up button look pretty
        signUpButton.layer.borderColor = opaqueColor.cgColor
        signUpButton.layer.cornerRadius = 6
        signUpButton.layer.borderWidth = 1
        signUpButton.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
        signUpButton.setTitleColor(opaqueColor, for: .normal)
        signUpButton.setTitleColor(opaqueColor, for: .highlighted)
        signUpButton.isEnabled = false
        
        // Create cut line above login button
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: self.view.frame.height - (self.view.frame.height - loginButton.frame.minY) - 10, width: self.view.frame.width, height: 1.0)
        layer.backgroundColor = opaqueColor.cgColor
        self.view.layer.addSublayer(layer)
        
        print("Sign up loaded")
    }
    
    // Embed the activity wheel into the right view in the textfields
    func setUpActivityWheel(activityWheel: UIActivityIndicatorView, textfield: UITextField) {
        textfield.rightViewMode = .always
        activityWheel.frame = CGRect(x: 0, y: 0, width: textfield.frame.height, height: textfield.frame.height)
        textfield.rightView = activityWheel
    }
    
    // Function to manage all the activity wheels at once
    func setActivityWheelsAnimating(state: Bool) {
        if state {
            usernameWheel.startAnimating()
            passwordWheel.startAnimating()
            emailWheel.startAnimating()
            groupIdWheel.startAnimating()
        } else {
            usernameWheel.stopAnimating()
            passwordWheel.stopAnimating()
            emailWheel.stopAnimating()
            groupIdWheel.stopAnimating()
        }
    }
    
    // Initiates sign up proccess
    @IBAction func initiateSignUp() {
        // todo: make it so they don't flash
        let validator = Validator()
        var valid = true
        
        // Check if the username, password, and email are valid. Animate them if they are not valid
        if !validator.isValidEmail(email: emailField.text!) {
            animateTextFieldError(textfield: emailField)
            valid = false
        } else {
            emailField.layer.borderWidth = 0
        }
        if !validator.isValidPassword(password: passwordField.text!) {
            animateTextFieldError(textfield: passwordField)
            valid = false
        } else {
            passwordField.layer.borderWidth = 0
        }
        
        if !validator.isValidUsername(username: usernameField.text!) {
            animateTextFieldError(textfield: usernameField)
            valid = false
        } else {
            usernameField.layer.borderWidth = 0
        }
        
        
        // Return from function if one of the text fields did not meet the correct criteria
        if !valid { return }
        
        // Set the wheels to animate...about to access the internet
        setActivityWheelsAnimating(state: true)
        
        // Attempt to create new user
        
        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) { user, error in
                                    if error == nil {
                                        // 3
                                        FIRAuth.auth()!.signIn(withEmail: self.emailField.text!,
                                                               password: self.passwordField.text!)
                                    }
        }
        
        /*
        KCSUser.user(
            withUsername: usernameField.text!,
            password: passwordField.text!,
            fieldsAndValues: [
                KCSUserAttributeEmail : emailField.text!,
                "groupIdentifier": groupIdField.text!
            ],
            withCompletionBlock: { (KCSUser, error, KCSUserActionResult) -> Void in
                if error == nil {
                    // Success ... go back to login view
                    self.sendToLogin("")
                } else {
                    //there was an error with the create
                    let e = error as! NSError
                    print("Error signing up: \(KCSUserActionResult), error = \(e.code)")
                    
                    switch e.code {
                    // todo: add more error codes
                        
                    // Username already exsists
                    case 60007:
                        self.animateTextFieldError(textfield: self.usernameField)
                        break
                    // Username already exsists
                    case 409:
                        self.animateTextFieldError(textfield: self.usernameField)
                        break
                        
                    default:
                        break
                    }
                }
                
                // Done access internet, stop animating wheels
                self.setActivityWheelsAnimating(state: false)
            }
        )*/
        
        
    }
    
    // Make textfields wiggle on error
    func animateTextFieldError(textfield: UITextField) {
        
        textfield.layer.borderWidth = 1
        
        let c = CABasicAnimation(keyPath: "borderColor")
        c.fromValue = textfield.layer.borderColor
        c.toValue = UIColor.red.cgColor
        c.duration = 0.2
        c.repeatCount = 0
        c.isRemovedOnCompletion = false
        c.fillMode = kCAFillModeForwards
        textfield.layer.borderWidth = 1
        textfield.layer.add(c, forKey: "borderColor")
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textfield.center.x - 10, y: textfield.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textfield.center.x + 10, y: textfield.center.y))
        textfield.layer.add(animation, forKey: "position")

    }
    
    // Return to login screen
    @IBAction func sendToLogin(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Move UI up if we're going to start editing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y - self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y - self.view.frame.height / 7)
            self.emailField.center = CGPoint(x: self.emailField.center.x, y: self.emailField.center.y - self.view.frame.height / 7)
            self.groupIdField.center = CGPoint(x: self.groupIdField.center.x, y: self.groupIdField.center.y - self.view.frame.height / 7)
            self.signUpButton.center = CGPoint(x: self.signUpButton.center.x, y: self.signUpButton.center.y - self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y - self.view.frame.height / 7)
        })
        
        return true
    }
    
    // Move UI back down after finishing editing
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y + self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y + self.view.frame.height / 7)
            self.emailField.center = CGPoint(x: self.emailField.center.x, y: self.emailField.center.y + self.view.frame.height / 7)
            self.groupIdField.center = CGPoint(x: self.groupIdField.center.x, y: self.groupIdField.center.y + self.view.frame.height / 7)
            self.signUpButton.center = CGPoint(x: self.signUpButton.center.x, y: self.signUpButton.center.y + self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y + self.view.frame.height / 7)
        })
        
        return true
    }
    
    // Determine what should be done when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            switch textField {
            case usernameField:
                passwordField.becomeFirstResponder()
                break
            case passwordField:
                emailField.becomeFirstResponder()
                break
            case emailField:
                groupIdField.becomeFirstResponder()
                break
                
            default:
                textField.resignFirstResponder()
            }
            
        } else if textField.returnKeyType == .go {
            textField.resignFirstResponder()
            initiateSignUp()
        }
        return true
    }
    // Determine if the textfields are valid after changing and can be submitted
    func textFieldDidChange() {
        if usernameField.text?.characters.count != 0 && passwordField.text?.characters.count != 0 && emailField.text?.characters.count != 0 && groupIdField.text?.characters.count != 0 {
            signUpButton.setTitleColor(.white, for: .normal)
            signUpButton.isEnabled = true
        } else {
            signUpButton.setTitleColor(opaqueColor, for: .normal)
            signUpButton.isEnabled = false
        }
    }
    
    // Hide keyboard if tapped away from keyboard and textfields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // Make the textfields look pretty
    func setUpTextField(imageNamed: String, placeholder: String, textfield: UITextField) {
        
        let padding : CGFloat = 25
        let radius : CGFloat = 6
        
        textfield.leftViewMode = UITextFieldViewMode.always
        let image = UIImage(named: imageNamed)
        
        if let image = image {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            textfield.leftView = imageView
            
        }

        textfield.borderStyle = .roundedRect
        textfield.layer.cornerRadius = radius
        textfield.backgroundColor = opaqueColor
        textfield.textColor = .white
        textfield.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: opaqueColor])
        
        textfield.enablesReturnKeyAutomatically = true
        
        textfield.tintColor = .white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
