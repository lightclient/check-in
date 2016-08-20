//
//  TabBarViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    
    //var contentLength: CGFloat = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITabBar.appearance().barTintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
        UITabBar.appearance().tintColor = UIColor(red:0.23, green:0.48, blue:0.84, alpha:1.0)
    
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)], for:.normal)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
