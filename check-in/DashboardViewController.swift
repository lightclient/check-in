//
//  DashboardViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class MainDashboardViewController: UIViewController, ElasticMenuTransitionDelegate {

    var transition = ElasticTransition()
    //let lgr = UIScreenEdgePanGestureRecognizer()
    //let rgr = UIScreenEdgePanGestureRecognizer()

    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = getRandomColor()
        
        // customization
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .translateMid
        
        //    transition.overlayColor = UIColor(white: 0, alpha: 0.5)
        //    transition.shadowColor = UIColor(white: 0, alpha: 0.5)
        
        /* gesture recognizer
        lgr.addTarget(self, action: #selector(self.handlePan(_:)))
        rgr.addTarget(self, action: #selector(self.handleRightPan(_:)))
        lgr.edges = .left
        rgr.edges = .right
        view.addGestureRecognizer(lgr)
        view.addGestureRecognizer(rgr)
    }

    
    func handlePan(_ pan:UIPanGestureRecognizer){
        if pan.state == .began{
            transition.edge = .left
            transition.startInteractiveTransition(self, segueIdentifier: "membersSegue", gestureRecognizer: pan)
        }else{
            _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    func handleRightPan(_ pan:UIPanGestureRecognizer){
        if pan.state == .began{
            transition.edge = .right
            transition.startInteractiveTransition(self, segueIdentifier: "eventsSegue", gestureRecognizer: pan)
        }else{
            _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
         } */ }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destination
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .custom
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return UIStatusBarStyle.default }

}
