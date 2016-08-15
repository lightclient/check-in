//
//  LoginViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Login loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func initiateLogin(_ sender: AnyObject) {
        
        KCSUser.login(
            withUsername: username.text!,
            password: password.text!,
            withCompletionBlock: { (KCSUserCompletionBlock) -> Void in
                if KCSUserCompletionBlock.1 == nil {
                    //the log-in was successful and the user is now the active user and credentials saved
                    //hide log-in view and show main app content
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
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
}


