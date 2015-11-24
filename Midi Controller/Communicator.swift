//
//  Communicator.swift
//  Midi Manipulation
//
//  Created by Riley Testut on 11/14/15.
//  Copyright © 2015 USC Hackers. All rights reserved.
//

import Foundation
import CoreGraphics

public struct QRCode
{
    let stringValue: String
    let relativePosition: CGPoint
}

private let currentPlayerIndex = 0

class Communicator: NSObject
{
    static let sharedCommunicator = Communicator()
    
    private override init()
    {
        
    }
    
    func sendSwipeUpEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.SwipeUp.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
        
        print("Swipe Up")
    }
    
    func sendSwipeRightEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.SwipeRight.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
        
        print("Swipe Right")
    }
    
    func sendSwipeLeftEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.SwipeLeft.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
        
        print("Swipe Left")
    }
    
    func sendSwipeDownEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.SwipeDown.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
        
        print("Swipe Down")
    }
    
    func sendShakeEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.Shake.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
        
        print("Shake")
    }
    
    func sendFingerTrackingEvent(normalizedPoint: CGPoint)
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.FingerTracking.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = normalizedPoint.x
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = normalizedPoint.x
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }
    
    func sendFinishedFingerTrackingEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.FinishedFingerTracking.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }
    
    func sendGuitarQRCodeEvent(code: QRCode?)
    {
        let event: CommunicatorEvent
        
        if code != nil
        {
            event = .GuitarQRCode
        }
        else
        {
            event = .NoGuitarQRCode
        }
        
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = event.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }
    
    func sendDrumsQRCodeEvent(code: QRCode?)
    {
        let event: CommunicatorEvent
        
        if code != nil
        {
            event = .DrumsQRCode
        }
        else
        {
            event = .NoDrumsQRCode
        }
        
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = event.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }
    
    func sendTapEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.Tap.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }
    
    func sendWatchTapEvent()
    {
        var playerIndex: Int = currentPlayerIndex
        let data = NSMutableData(bytes: &playerIndex, length: sizeof(Int))
        
        var value: Int16 = CommunicatorEvent.WatchTap.rawValue
        data.appendBytes(&value, length: sizeof(Int16))
        
        var x = 0
        data.appendBytes(&x, length: sizeof(CGFloat))
        
        var y = 0
        data.appendBytes(&y, length: sizeof(CGFloat))
        
        GBABluetoothLinkManager.sharedManager().sendData(data, toPlayerAtIndex: 0)
    }

}
