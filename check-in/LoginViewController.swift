//
//  LoginViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    /* -------------------------------------------------------- */
    
    let opaqueColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.2)
    
    let usernameWheel = UIActivityIndicatorView()
    let passwordWheel = UIActivityIndicatorView()

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    /* -------------------------------------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the pretty gradient
        loadBackgroundGradient()
        
        // Create target to be called when the text fields are changed (to determine if the input is valid)
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        // Make the text fields look pretty
        setUpTextField(imageNamed: "user.png", placeholder: "Username", textfield: usernameField)
        setUpTextField(imageNamed: "lock.png", placeholder: "Password", textfield: passwordField)
        
        // Set up login button
        loginButton.layer.borderColor = opaqueColor.cgColor
        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 1
        loginButton.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
        loginButton.setTitleColor(opaqueColor, for: .normal)
        loginButton.setTitleColor(opaqueColor, for: .highlighted)
        loginButton.isEnabled = false
        
        // Add cutline above signup button
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: self.view.frame.height - (self.view.frame.height - signUpButton.frame.minY) - 10, width: self.view.frame.width, height: 1.0)
        layer.backgroundColor = opaqueColor.cgColor
        self.view.layer.addSublayer(layer)
        
        print("Login loaded")
    }
    
    // Called when its time to start login
    @IBAction func initiateLogin(_ sender: AnyObject) {
        
        // Begin animating activity wheels to avoid laggy appearance
        usernameWheel.startAnimating()
        passwordWheel.startAnimating()
        
        KCSUser.login(
            withUsername: usernameField.text!,
            password: passwordField.text!,
            withCompletionBlock: { (KCSUserCompletionBlock) -> Void in
                
                self.usernameWheel.stopAnimating()
                self.passwordWheel.stopAnimating()
                
                if KCSUserCompletionBlock.1 == nil {
                    //the log-in was successful and the user is now the active user and credentials saved
                    //hide log-in view and show main app content
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    tabBarController.modalTransitionStyle = .flipHorizontal
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController?.present(tabBarController, animated: true, completion: nil)
                } else {
                    //there was an error with the update save
                    let code = (KCSUserCompletionBlock.1 as! NSError).code
                    print(code)
                    
                    //todo: add other error codes
                    
                    switch(code) {
                    // incorrect credentials
                    case 401:
                        self.animateTextFieldError(textfield: self.usernameField)
                        self.animateTextFieldError(textfield: self.passwordField)
                        break
                    default:
                        break
                    }
                }
            }
        )
    }

    // Make the textfield wiggle back and forth & become outlined in red
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

    // Present the sign up view
    @IBAction func sendToSignUp(_ sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Move the UI up if we're about to begin editing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y - self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y - self.view.frame.height / 7)
            self.loginButton.center = CGPoint(x: self.loginButton.center.x, y: self.loginButton.center.y - self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y - self.view.frame.height / 7)
        })
        
        return true
    }
    
    // Move the UI back down if we're done editing
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y + self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y + self.view.frame.height / 7)
            self.loginButton.center = CGPoint(x: self.loginButton.center.x, y: self.loginButton.center.y + self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y + self.view.frame.height / 7)
        })
        
        return true
    }
    
    // Determine what to do when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            passwordField.becomeFirstResponder()
        } else if textField.returnKeyType == .go {
            textField.resignFirstResponder()
            initiateLogin("")
        }
        
        
        return true
    }
    
    // Determine if we can submit the username and password fields & enable the login button if we can
    func textFieldDidChange() {
        if usernameField.text?.characters.count != 0 && passwordField.text?.characters.count != 0 {
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.isEnabled = true
        } else {
            loginButton.setTitleColor(opaqueColor, for: .normal)
            loginButton.isEnabled = false
        }
    }
    
    // Make the keyboard disappear if we touch away from the keyboard or a textfield
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
    
    // Make the backgroud look pretty
    func loadBackgroundGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0).cgColor, UIColor(red:0.23, green:0.38, blue:0.45, alpha:1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.2, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}


