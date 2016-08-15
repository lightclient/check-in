//
//  SignupViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/13/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var groupID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Signup loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func initiateSignup(_ sender: AnyObject) {
 
        KCSUser.user(
            withUsername: username.text!,
            password: password.text!,
            fieldsAndValues: [ "groupIdentifier": groupID.text!],
            withCompletionBlock: { (KCSUserCompletionBlock) -> Void in
                if KCSUserCompletionBlock.1 == nil {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = viewController
                } else {
                    //there was an error with the create
                    print("Error signing up")
                }
            }
        )
        

    }
}
