//
//  scannerViewController.swift
//  check-in
//
//  Created by Matt Garnett on 8/13/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScannerTableViewDelegate {
    
    
    /* -------------------------------------------------------- */
    
    // Scanner vars
    let session         : AVCaptureSession = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    var highlightView   : UIView = UIView()
    
    // TableViewController instance
    var tableViewController: ScannerTableViewController!
    
    // Event var that is updated with new attendees
    var event : Event?
    
    /* -------------------------------------------------------- */

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add camera button to reset capture
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(restartCapture))
        navigationItem.rightBarButtonItem = reloadButton
        
        // Add table view controller to view
        addTableBarView()
        
        // Hide the tab bar from this part of the app
        setTabBarVisible(visible: false, animated: true)
        
        // Set the color completed scan reticle
        self.highlightView.layer.borderColor = UIColor.green.cgColor
        self.highlightView.layer.borderWidth = 5
        
        // Add it to the controller's view as a subview.
        self.view.addSubview(self.highlightView)
        
        // Create instance of the camera
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the "var" keyword and not "let"
        let error : NSError? = nil
        
        let input : AVCaptureDeviceInput? = try? AVCaptureDeviceInput.init(device: device)
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
        if input != nil {
            session.addInput(input)
        }
        else {
            // This is fine for a demo, do something real with this in your app. :)
            print(error)
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // Add the camera view to our view
        previewLayer = AVCaptureVideoPreviewLayer.init(session: session) as AVCaptureVideoPreviewLayer
        previewLayer.frame = CGRect(x: 0, y: self.view.bounds.height / 2, width: self.view.bounds.width, height: self.view.bounds.height / 2)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        // Start the scanner
        session.startRunning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setTabBarVisible(visible: true, animated: true)
    }
    
    func readyToCaptureAgain() {
        self.highlightView.frame = CGRect.zero
        session.startRunning()
    }
    
    func restartCapture() {
        tableViewController.loadTextFields(m: Member())
        readyToCaptureAgain()
    }
    
    // Called when known barcode is detected
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, from connection: AVCaptureConnection!) {
        
        // Begin animating the wheels to avoid UI lag
        wheelsAreAnimating(b: true)
        
        var highlightViewRect = CGRect.zero
        var barCodeObject : AVMetadataObject!
        var detectionString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeAztecCode
        ]
        
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                
                if metadata.type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    
                    let bounds = CGRect(x: barCodeObject.bounds.minX, y: barCodeObject.bounds.minY + view.frame.height / 2, width: barCodeObject.bounds.width, height: barCodeObject.bounds.height)
                    highlightViewRect = bounds
                    
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    
                    self.session.stopRunning()
                    break
                }
            }
        }
        
        // Update text fields with the id (and any data from the backend if we find it)
        tableViewController?.didCaptureBarcode(barcode: detectionString)
        
        // Add the reticle
        self.highlightView.frame = highlightViewRect
        self.view.bringSubview(toFront: self.highlightView)
    }
    
    func wheelsAreAnimating(b: Bool) {
        let t = tableViewController
        
        if b {
            t?.nameWheel.startAnimating()
            t?.emailWheel.startAnimating()
            t?.idWheel.startAnimating()
        } else {
            t?.nameWheel.stopAnimating()
            t?.emailWheel.stopAnimating()
            t?.idWheel.stopAnimating()
        }
    }
    
    func addTableBarView() {
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // Setup constraits
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
        
        // Create instance of tableViewController
        tableViewController = storyboard!.instantiateViewController(withIdentifier: "ScannerTableViewController") as! ScannerTableViewController
        
        // Add the view controller as child to current view controller
        addChildViewController(tableViewController)
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the view controller's view to the container view
        containerView.addSubview(tableViewController.view)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        tableViewController.didMove(toParentViewController: self)
        tableViewController.delegate = self
        
        tableViewController.event = event!
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if ( (self.tabBarController?.tabBar.frame.origin.y < self.view.frame.maxY) == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
}
