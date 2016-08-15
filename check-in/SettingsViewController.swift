//
//  SecondViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/12/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Settings loaded")
        KCSUser.active().logout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

