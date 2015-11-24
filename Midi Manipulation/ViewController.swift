//
//  ViewController.swift
//  Midi Manipulation
//
//  Created by Hannah Criswell on 11/14/15.
//  Copyright © 2015 USC Hackers. All rights reserved.
//

import UIKit

import AVFoundation
import AVKit
import CoreImage
import GameController

class ViewController: UIViewController {
    
    private let queue = dispatch_queue_create("com.usc-hackers.Quark.waitingQueue", DISPATCH_QUEUE_SERIAL)
   
    @IBOutlet weak var view1: UIView!
    var controller1 = AVPlayerViewController()
    
  
    @IBOutlet weak var view2: UIView!
    var controller2 = AVPlayerViewController()

    
    @IBOutlet weak var view3: UIView!
    var controller3 = AVPlayerViewController()

    
    @IBOutlet weak var view4: UIView!
    var controller4 = AVPlayerViewController()
    
    let filters1 = ["pixel" : CIFilter(name: "CIPixellate", withInputParameters: ["inputScale" : 1])!,
                    "pinch" : CIFilter(name: "CIPinchDistortion", withInputParameters: ["inputScale" : 0, "inputCenter" : CIVector(x: 960, y: 540)])!,
        "color" : CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor" : CIColor(color: UIColor.clearColor()), "inputIntensity": 0])!]
    
    let filters2 = ["pixel" : CIFilter(name: "CIPixellate", withInputParameters: ["inputScale" : 1])!,
        "pinch" : CIFilter(name: "CIPinchDistortion", withInputParameters: ["inputScale" : 0, "inputCenter" : CIVector(x: 960, y: 540)])!,
        "color" : CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor" : CIColor(color: UIColor.clearColor()), "inputIntensity": 0])!]
    
    let filters3 = ["pixel" : CIFilter(name: "CIPixellate", withInputParameters: ["inputScale" : 1])!,
        "pinch" : CIFilter(name: "CIPinchDistortion", withInputParameters: ["inputScale" : 0, "inputCenter" : CIVector(x: 960, y: 540)])!,
        "color" : CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor" : CIColor(color: UIColor.clearColor()), "inputIntensity": 0])!]
    
    let filters4 = ["pixel" : CIFilter(name: "CIPixellate", withInputParameters: ["inputScale" : 1])!,
        "pinch" : CIFilter(name: "CIPinchDistortion", withInputParameters: ["inputScale" : 0, "inputCenter" : CIVector(x: 960, y: 540)])!,
        "color" : CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor" : CIColor(color: UIColor.clearColor()), "inputIntensity": 0])!]
    
    let colorList = [CIColor(color: UIColor.clearColor()), CIColor(color: UIColor.redColor()), CIColor(color: UIColor.greenColor()), CIColor(color: UIColor.blueColor())]
    
    var boolList = [false, false, false, false]
    
    var colorCounter = 0
    
    var playerFilters: [[String : CIFilter]]!
    
    var bassPlayer:AVAudioPlayer = AVAudioPlayer()
    var baseTrackPlayer:AVAudioPlayer = AVAudioPlayer()
    var drumPlayer:AVAudioPlayer = AVAudioPlayer()
    var guitarPlayer:AVAudioPlayer = AVAudioPlayer()
    var cowbellPlayer: AVAudioPlayer!


    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.playerFilters = [filters1, filters2, filters3, filters4]
        
        let url1 = NSBundle.mainBundle().URLForResource("concert_exported", withExtension: "mov")
        let url2 = NSBundle.mainBundle().URLForResource("lake_exported", withExtension: "mov")
        let url3 = NSBundle.mainBundle().URLForResource("la_skyline_exported", withExtension: "mov")
        let url4 = NSBundle.mainBundle().URLForResource("rave_exported", withExtension: "mov")
        
        let playerItem1 = AVPlayerItem(URL: url1!)
        let playerItem2 = AVPlayerItem(URL: url2!)
        let playerItem3 = AVPlayerItem(URL: url3!)
        let playerItem4 = AVPlayerItem(URL: url4!)
        
        
        let player1 = AVPlayer(playerItem: playerItem1)
        let player2 = AVPlayer(playerItem: playerItem2)
        let player3 = AVPlayer(playerItem: playerItem3)
        let player4 = AVPlayer(playerItem: playerItem4)
        
        
        
        
        let closure = { (playerIndex: Int, request: AVAsynchronousCIImageFilteringRequest) in
            
            let filters = self.playerFilters[playerIndex]
            
            var image = request.sourceImage
            
            for (_, value) in filters
            {
                value.setValue(image, forKey: "inputImage")
                image = value.outputImage!
            }
            
            request.finishWithImage(image, context: nil)
            
        }
        
        
        let composition1 = AVMutableVideoComposition(asset: AVAsset(URL: url1!)) { (request) -> Void in
            closure(0, request)
        }
        
        let composition2 = AVMutableVideoComposition(asset: AVAsset(URL: url2!)) { (request) -> Void in
            closure(1, request)
        }
        
        let composition3 = AVMutableVideoComposition(asset: AVAsset(URL: url3!)) { (request) -> Void in
            closure(2, request)
        }
        
        let composition4 = AVMutableVideoComposition(asset: AVAsset(URL: url4!)) { (request) -> Void in
            closure(3, request)
        }
        
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        
        try! AVAudioSession.sharedInstance().setActive(true)
            
        playerItem1.videoComposition = composition1;
        playerItem2.videoComposition = composition2;
        playerItem3.videoComposition = composition3;
        playerItem4.videoComposition = composition4;
        
        self.addChildViewController(controller1)
        self.addChildViewController(controller2)
        self.addChildViewController(controller3)
        self.addChildViewController(controller4)
        
        // Do any additional setup after loading the view, typically from a nib.
        controller1.view.translatesAutoresizingMaskIntoConstraints = false//were forcing our own auto layout
        controller1.player = player1
        controller2.view.translatesAutoresizingMaskIntoConstraints = false
        controller2.player = player2
        controller3.view.translatesAutoresizingMaskIntoConstraints = false
        controller3.player = player3
        controller4.view.translatesAutoresizingMaskIntoConstraints = false
        controller4.player = player4
        
        self.view1.addSubview(controller1.view)
        self.view2.addSubview(controller2.view)
        self.view3.addSubview(controller3.view)
        self.view4.addSubview(controller4.view)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "loopVideo:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player1.currentItem!)
        notificationCenter.addObserver(self, selector: "loopVideo:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player2.currentItem!)
        notificationCenter.addObserver(self, selector: "loopVideo:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player3.currentItem!)
        notificationCenter.addObserver(self, selector: "loopVideo:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player4.currentItem!)
        
        player1.actionAtItemEnd = .None
        player2.actionAtItemEnd = .None
        player3.actionAtItemEnd = .None
        player4.actionAtItemEnd = .None
        
        player1.play()
        player2.play()
        player3.play()
        player4.play()
        
        
        let baseTrackPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bassTrack", ofType: "mp3")!)
        let drumPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("drums", ofType: "mp3")!)
        let guitarPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("guitars", ofType: "mp3")!)
        let cowbellPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cowbell", ofType: "mp3")!)

        
        do{
            self.baseTrackPlayer = try AVAudioPlayer(contentsOfURL:baseTrackPath)
            self.baseTrackPlayer.numberOfLoops = -1
            self.baseTrackPlayer.volume = 0.8
            self.baseTrackPlayer.prepareToPlay()
        }catch {
            print("Error getting the audio file")
        }
        
        
        do{
            self.drumPlayer = try AVAudioPlayer(contentsOfURL:drumPath)
            self.drumPlayer.numberOfLoops = -1
            self.drumPlayer.volume = 0
            self.drumPlayer.prepareToPlay()
        }catch {
            print("Error getting the audio file")
        }
        
        
        do{
            self.guitarPlayer = try AVAudioPlayer(contentsOfURL:guitarPath)
            self.guitarPlayer.numberOfLoops = -1
            self.guitarPlayer.volume = 0
            self.guitarPlayer.prepareToPlay()
        }catch{
            print("Error getting the audio file")
        }
        
        do{
            self.cowbellPlayer = try AVAudioPlayer(contentsOfURL:guitarPath)
            self.cowbellPlayer.numberOfLoops = 1
            self.cowbellPlayer.prepareToPlay()
        }catch{
            print("Error getting the audio file")
        }
        
        //playerAtIndexDidSwipeUp(3);
        //auto layout//H=horizontal V=vertical //| means super view, its parent view
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controller1]|", options: [], metrics: nil, views: ["controller1": controller1.view]))
        
         NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controller2]|", options: [], metrics: nil, views: ["controller2": controller2.view]))
        
         NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controller3]|", options: [], metrics: nil, views: ["controller3": controller3.view]))
        
         NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controller4]|", options: [], metrics: nil, views: ["controller4": controller4.view]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controller1]|", options: [], metrics: nil, views: ["controller1": controller1.view]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controller2]|", options: [], metrics: nil, views: ["controller2": controller2.view]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controller3]|", options: [], metrics: nil, views: ["controller3": controller3.view]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controller4]|", options: [], metrics: nil, views: ["controller4": controller4.view]))

    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)//makes sure that we dont continue to get messages when deallocated
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.baseTrackPlayer.play()
        self.drumPlayer.play()
        self.guitarPlayer.play()
        
        if GBABluetoothLinkManager.sharedManager().connectedPeers.count == 0
        {
            let viewController = UINavigationController(rootViewController: LinkViewController())
            self.presentViewController(viewController, animated: true, completion: nil)
        }
        
        dispatch_async(self.queue) {
            
            while true
            {
                if GBABluetoothLinkManager.sharedManager().waitForLinkDataWithTimeout(100000)
                {
                    var playerData: NSData?
                    GBABluetoothLinkManager.sharedManager().receiveData(&playerData, withMaxSize: UInt(sizeof(Int)), fromPlayerAtIndex: 0)
                    
                    var data: NSData?
                    GBABluetoothLinkManager.sharedManager().receiveData(&data, withMaxSize: UInt(sizeof(Int16)), fromPlayerAtIndex: 0)
                    
                    var data2: NSData?
                    GBABluetoothLinkManager.sharedManager().receiveData(&data2, withMaxSize: UInt(sizeof(CGFloat)), fromPlayerAtIndex: 0)
                    
                    var data3: NSData?
                    GBABluetoothLinkManager.sharedManager().receiveData(&data3, withMaxSize: UInt(sizeof(CGFloat)), fromPlayerAtIndex: 0)
                    
                    var playerIndex: Int = 0
                    playerData?.getBytes(&playerIndex, length: sizeof(Int))
                    
                    var type: Int16 = 0
                    data?.getBytes(&type, length: sizeof(Int16))
                    
                    var variableA: CGFloat = 0
                    data2?.getBytes(&variableA, length: sizeof(CGFloat))
                    
                    var variableB: CGFloat = 0
                    data3?.getBytes(&variableB, length: sizeof(CGFloat))
                    
                    if let event = CommunicatorEvent(rawValue: type)
                    {
                        self.updateWithEvent(event, playerIndex: playerIndex, variableA: variableA, variableB: variableB)
                    }
                }
            }
        }
    }
    
    func updateWithEvent(event: CommunicatorEvent, playerIndex index: Int, variableA: CGFloat, variableB: CGFloat)
    {
        guard index < 4 && index >= 0 else { return }
        
        print(event)
        
        switch event
        {
        case .SwipeUp: self.playerAtIndexDidSwipeUp(index)
        case .SwipeDown: self.playerAtIndexDidSwipeDown(index)
        case .SwipeLeft: break
        case .SwipeRight: break
        case .Shake: self.playerAtIndexDidShake(index)
        case .FingerTracking: self.playerAtIndexDidTrack(index, playerPoint: CGPointMake(variableA, variableB))
        case .FinishedFingerTracking: self.playerAtIndexDidFinishTracking(index)
        case .GuitarQRCode: self.playerAtIndexDidShowGuitarQRCode(index)
        case .NoGuitarQRCode: self.playerAtIndexDidHideGuitarQRCode(index)
        case .DrumsQRCode: self.playerAtIndexDidShowDrumsQRCode(index)
        case .NoDrumsQRCode: self.playerAtIndexDidHideDrumsQRCode(index)
        case .Tap: self.playerAtIndexDidTap(index)
        case .WatchTap: self.playerAtIndexDidTapWatch(index)
        }
    }
    
    @objc func loopVideo(notifcation: NSNotification)
    {
        let player = notifcation.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)//special time value that means zero
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerAtIndexDidSwipeUp(index: Int)
    {
        let player = self.playerFilters[index]
        
        let filter = player["color"]!
        
        colorCounter++
        
        if(colorCounter == self.colorList.count)
        {
            colorCounter = 0
        }
       
        if(colorCounter == 0)
        {
            filter.setValue(0, forKey: "inputIntensity")
        }
        else
        {
            filter.setValue(1, forKey: "inputIntensity")
        }

        filter.setValue(colorList[colorCounter], forKey: "inputColor")
    }
    
    func playerAtIndexDidSwipeDown(index: Int)
    {
        let player = self.playerFilters[index]
        
        let filter = player["color"]!
        
        colorCounter--
        
        if(colorCounter == -1)
        {
            colorCounter = self.colorList.count - 1
        }
        
        
        if(colorCounter == 0)
        {
            filter.setValue(0, forKey: "inputIntensity")
        }
        else
        {
            filter.setValue(1, forKey: "inputIntensity")
        }
        
        filter.setValue(colorList[colorCounter], forKey: "inputColor")
    }
    
    
    func playerAtIndexDidShake(index: Int)
    {
        let player = self.playerFilters[index]
        
        let filter = player["pixel"]!
        
        if boolList[index] == true
        {
            filter.setValue(1, forKey: "inputScale")
            boolList[index] = false
        }
        else
        {
            filter.setValue(20.0, forKey: "inputScale")
            boolList[index] = true
        }
        
    }
    
    func playerAtIndexDidTrack(index: Int, playerPoint: CGPoint)
    {        
        let player = self.playerFilters[index]
        
        let filter = player["pinch"]!
        
        filter.setValue(CIVector(x: playerPoint.x * 1920,y: playerPoint.y * 1080), forKey: "inputCenter")
        filter.setValue(0.75, forKey: "inputScale")
    }
    
    func playerAtIndexDidFinishTracking(index: Int)
    {
        let player = self.playerFilters[index]
        
        let filter = player["pinch"]!
        filter.setValue(0, forKey: "inputScale")
    }

    
    func playerAtIndexDidShowGuitarQRCode(index: Int)
    {
        self.guitarPlayer.volume = 0.8;
    }
    
    func playerAtIndexDidHideGuitarQRCode(index: Int)
    {
        self.guitarPlayer.volume = 0.0
    }
    
    func playerAtIndexDidShowDrumsQRCode(index: Int)
    {
        self.drumPlayer.volume = 1.0
    }
    
    func playerAtIndexDidHideDrumsQRCode(index: Int)
    {
        self.drumPlayer.volume = 0.0
    }
    
    
    func playerAtIndexDidTap(index: Int)
    {
        dispatch_async(dispatch_get_main_queue()) {
            
            let animation = CATransition()
            
            animation.duration = 1
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = "rippleEffect"
            
            if(index == 0)
            {
                self.view1.layer.addAnimation(animation, forKey: nil)
            }
            
            if(index == 1)
            {
                self.view2.layer.addAnimation(animation, forKey: nil)
            }
            
            if(index == 2)
            {
                self.view3.layer.addAnimation(animation, forKey: nil)
            }
            
            if(index == 3)
            {
                self.view4.layer.addAnimation(animation, forKey: nil)
            }
            
        }
        
    }
    
    func playerAtIndexDidTapWatch(index: Int)
    {
        self.cowbellPlayer.play()
    }

}

