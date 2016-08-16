//
//  DashboardPageViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class DashboardPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    let rgr = UIScreenEdgePanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        delegate = self
        
        self.transitionStyle = .pageCurl
        
        // customization
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.3
        transition.transformType = .translateMid
        
        //    transition.overlayColor = UIColor(white: 0, alpha: 0.5)
        //    transition.shadowColor = UIColor(white: 0, alpha: 0.5)
        
        // gesture recognizer
        lgr.addTarget(self, action: #selector(self.handlePan(_:)))
        rgr.addTarget(self, action: #selector(self.handleRightPan(_:)))
        lgr.edges = .left
        rgr.edges = .right
        view.addGestureRecognizer(lgr)
        view.addGestureRecognizer(rgr)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destination
        vc.transitioningDelegate = transition
        vc.modalPresentationStyle = .custom
    }
    
    func pageViewController(_ viewControllerBeforepageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ viewControllerAfterpageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(type: "Events"),
                self.newViewController(type: ""),
                self.newViewController(type: "Members")]
    }()
    
    private func newViewController(type: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(type)DashboardViewController")
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
