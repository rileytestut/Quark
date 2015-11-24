//
//  ViewController.swift
//  Midi Controller
//
//  Created by Riley Testut on 11/14/15.
//  Copyright © 2015 USC Hackers. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import Foundation
import WatchConnectivity

class ViewController: UIViewController
{
    private var session: WCSession! = nil
    private var cameraController = CameraController(metadataType: (UIDevice.currentDevice().userInterfaceIdiom == .Phone) ? AVMetadataObjectTypeAztecCode : AVMetadataObjectTypeFace)
    
    private var trackingFinger = false
    private var previousQRCode: QRCode?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if WCSession.isSupported()
        {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
        
        self.cameraController.delegate = self
        
        self.view.layer.addSublayer(self.cameraController.previewLayer)
        
        let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        upSwipeGestureRecognizer.direction = [.Up]
        self.view.addGestureRecognizer(upSwipeGestureRecognizer)
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        downSwipeGestureRecognizer.direction = [.Down]
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        leftSwipeGestureRecognizer.direction = [.Left]
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        rightSwipeGestureRecognizer.direction = [.Right]
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        self.view.addGestureRecognizer(longPressGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.requireGestureRecognizerToFail(panGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()
        
        self.cameraController.startSession()
        
        if GBABluetoothLinkManager.sharedManager().connectedPeers.count == 0
        {
            let viewController = UINavigationController(rootViewController: LinkViewController())
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cameraController.previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?)
    {
        guard event?.subtype == .MotionShake else { return }
        
        Communicator.sharedCommunicator.sendShakeEvent()
    }
}

private extension ViewController
{
    dynamic func handleSwipeGesture(gestureRecognizer: UISwipeGestureRecognizer)
    {
        switch gestureRecognizer.direction
        {
        case UISwipeGestureRecognizerDirection.Up: Communicator.sharedCommunicator.sendSwipeUpEvent()
        case UISwipeGestureRecognizerDirection.Down: Communicator.sharedCommunicator.sendSwipeDownEvent()
        case UISwipeGestureRecognizerDirection.Left: Communicator.sharedCommunicator.sendSwipeLeftEvent()
        case UISwipeGestureRecognizerDirection.Right: Communicator.sharedCommunicator.sendSwipeRightEvent()
        default: break
        }
    }
    
    dynamic func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == .Began
        {
            self.trackingFinger = true
        }
        else if gestureRecognizer.state != .Changed
        {
            Communicator.sharedCommunicator.sendFinishedFingerTrackingEvent()
            
            self.trackingFinger = false
        }
    }
    
    dynamic func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer)
    {
        guard self.trackingFinger else { return }
        
        var point = gestureRecognizer.locationInView(self.view)
        point.x /= self.view.bounds.width
        point.y /= self.view.bounds.height
        
        Communicator.sharedCommunicator.sendFingerTrackingEvent(point)
    }
    
    dynamic func handleTapGesture(gestureRecognzier: UITapGestureRecognizer)
    {
        guard gestureRecognzier.state == .Recognized else { return }
        
        Communicator.sharedCommunicator.sendTapEvent()
    }
}

extension ViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: WCSessionDelegate
{
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        if let shouldPlayCowbell = message["more_cowbell?"] as? Bool
        {
            
        }
        
    }
}

extension ViewController: CameraControllerDelegate
{
    func cameraController(cameraController: CameraController, didUpdateFaceCount faceCount: Int)
    {
        guard self.traitCollection.userInterfaceIdiom == .Pad else { return }
        
        print("Face Count: \(faceCount)")
    }
    
    func cameraController(cameraController: CameraController, didUpdateQRCode code: QRCode?)
    {
        guard self.traitCollection.userInterfaceIdiom == .Phone else { return }
        
        if let code = code
        {
            if code.stringValue == "guitar"
            {
                Communicator.sharedCommunicator.sendGuitarQRCodeEvent(code)
                self.previousQRCode = code
            }
            else
            {
                Communicator.sharedCommunicator.sendDrumsQRCodeEvent(code)
                self.previousQRCode = code
            }
        }
        else
        {
            if self.previousQRCode?.stringValue == "guitar"
            {
                Communicator.sharedCommunicator.sendGuitarQRCodeEvent(nil)
            }
            else
            {
                Communicator.sharedCommunicator.sendDrumsQRCodeEvent(nil)
            }            
            
            self.previousQRCode = nil
        }
        
        print(code?.relativePosition)
    }
}
