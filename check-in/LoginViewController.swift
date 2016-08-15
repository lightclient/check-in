//
//  LoginViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let opaqueColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.2)
    
    let usernameWheel = UIActivityIndicatorView()
    let passwordWheel = UIActivityIndicatorView()

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let padding : CGFloat = 25
        let radius : CGFloat = 6
        
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        usernameField.leftViewMode = UITextFieldViewMode.always
        let user = UIImage(named: "user.png")
        
        if let user = user {
            let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: user.size.width + padding, height: user.size.height))
            userImageView.image = user
            userImageView.contentMode = .scaleAspectFit
            usernameField.leftView = userImageView
            
        }
        
        usernameField.rightViewMode = .always
        usernameWheel.frame = CGRect(x: 0, y: 0, width: usernameField.frame.height, height: usernameField.frame.height)
        usernameField.rightView = usernameWheel
        
        usernameField.borderStyle = .roundedRect
        usernameField.layer.cornerRadius = radius
        usernameField.backgroundColor = opaqueColor
        usernameField.textColor = .white
        usernameField.attributedPlaceholder = NSAttributedString(string:"Username", attributes: [NSForegroundColorAttributeName: opaqueColor])
        
        usernameField.enablesReturnKeyAutomatically = true
        
        usernameField.tintColor = .white
        
        passwordField.leftViewMode = UITextFieldViewMode.always
        let lock = UIImage(named: "lock.png")
        
        if let lock = lock {
            let lockImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: lock.size.width + padding, height: lock.size.height))
            lockImageView.image = lock
            lockImageView.contentMode = .scaleAspectFit
            passwordField.leftView = lockImageView
            
        }
        
        passwordField.rightViewMode = .always
        passwordWheel.frame = CGRect(x: 0, y: 0, width: passwordField.frame.height, height: passwordField.frame.height)
        passwordField.rightView = passwordWheel
        
        passwordField.borderStyle = .roundedRect
        passwordField.layer.cornerRadius = radius
        passwordField.backgroundColor = opaqueColor
        passwordField.textColor = .white
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [NSForegroundColorAttributeName: opaqueColor])
        
        passwordField.enablesReturnKeyAutomatically = true
        
        passwordField.tintColor = .white
        
        loginButton.layer.borderColor = opaqueColor.cgColor
        loginButton.layer.cornerRadius = radius
        loginButton.layer.borderWidth = 1
        loginButton.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)
        loginButton.setTitleColor(opaqueColor, for: .normal)
        loginButton.setTitleColor(opaqueColor, for: .highlighted)
        loginButton.isEnabled = false
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: self.view.frame.height - (self.view.frame.height - signUpButton.frame.minY) - 10, width: self.view.frame.width, height: 1.0)
        layer.backgroundColor = opaqueColor.cgColor
        self.view.layer.addSublayer(layer)
        
        print("Login loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func initiateLogin(_ sender: AnyObject) {
        
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
                    let message = KCSUserCompletionBlock.1?.localizedDescription
                    let alert = UIAlertController(title: NSLocalizedString("Login failed", comment: "Sign account failed"), message: message, preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: {(action) -> Void in
                        print("Okay...")
                    })
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        )
        

    }
    
    @IBAction func sendToSignUp(_ sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y - self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y - self.view.frame.height / 7)
            self.loginButton.center = CGPoint(x: self.loginButton.center.x, y: self.loginButton.center.y - self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y - self.view.frame.height / 7)
        })
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, animations: {
            self.usernameField.center = CGPoint(x: self.usernameField.center.x, y: self.usernameField.center.y + self.view.frame.height / 7)
            self.passwordField.center = CGPoint(x: self.passwordField.center.x, y: self.passwordField.center.y + self.view.frame.height / 7)
            self.loginButton.center = CGPoint(x: self.loginButton.center.x, y: self.loginButton.center.y + self.view.frame.height / 7)
            self.logo.center = CGPoint(x: self.logo.center.x, y: self.logo.center.y + self.view.frame.height / 7)
        })
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            passwordField.becomeFirstResponder()
        } else if textField.returnKeyType == .go {
            textField.resignFirstResponder()
            initiateLogin("")
        }
        
        
        return true
    }
    
    func textFieldDidChange() {
        if usernameField.text?.characters.count != 0 && passwordField.text?.characters.count != 0 {
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.isEnabled = true
        } else {
            loginButton.setTitleColor(opaqueColor, for: .normal)
            loginButton.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func loadBackground() {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0).cgColor, UIColor(red:0.23, green:0.38, blue:0.45, alpha:1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.2, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
    }
}


