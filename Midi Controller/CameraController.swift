//
//  CameraController.swift
//  Midi Manipulation
//
//  Created by Riley Testut on 11/14/15.
//  Copyright © 2015 USC Hackers. All rights reserved.
//

import AVFoundation

protocol CameraControllerDelegate: class
{
    func cameraController(cameraController: CameraController, didUpdateFaceCount faceCount: Int)
    func cameraController(cameraController: CameraController, didUpdateQRCode QRCode: QRCode?)
}

class CameraController: NSObject
{
    weak var delegate: CameraControllerDelegate?
    
    let previewLayer: AVCaptureVideoPreviewLayer
    
    private let sessionQueue = dispatch_queue_create("com.uschackers.CameraController", DISPATCH_QUEUE_SERIAL)
    private let captureSession: AVCaptureSession
    private let metadataOutput: AVCaptureMetadataOutput
    
    init(metadataType: String)
    {
        let metadataQueue = dispatch_queue_create("com.uschackers.CameraController.videoBufferQueue", DISPATCH_QUEUE_SERIAL)
        dispatch_set_target_queue(metadataQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
        
        self.metadataOutput = AVCaptureMetadataOutput()
        self.captureSession = AVCaptureSession()
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        super.init()
        
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        
        self.metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        
        var captureDevice: AVCaptureDevice? = nil
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        {
            let cameraDevice = device as! AVCaptureDevice
            
            if device.position == .Back
            {
                captureDevice = cameraDevice
                break
            }
        }
        
        if let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        {
            dispatch_async(self.sessionQueue) {
                
                self.captureSession.beginConfiguration()
                
                self.captureSession.addInput(captureDeviceInput)
                self.captureSession.addOutput(self.metadataOutput)
                
                print(self.metadataOutput.availableMetadataObjectTypes)
                self.metadataOutput.metadataObjectTypes = [metadataType]
                
                self.captureSession.commitConfiguration()
            }
        }        
    }
    
    func startSession()
    {
        dispatch_async(self.sessionQueue) {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession()
    {
        dispatch_async(self.sessionQueue) {
            self.captureSession.stopRunning()
        }
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate
{
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        if metadataObjects.count == 0
        {
            self.delegate?.cameraController(self, didUpdateQRCode: nil)
            self.delegate?.cameraController(self, didUpdateFaceCount: 0)
            
            return
        }
        
        for object in metadataObjects
        {
            if let machineReadableCodeObject = object as? AVMetadataMachineReadableCodeObject
            {
                if let stringValue = machineReadableCodeObject.stringValue
                {
                    let transformedMetadataObject = self.previewLayer.transformedMetadataObjectForMetadataObject(machineReadableCodeObject)
                    
                    let point = CGPoint(x: transformedMetadataObject.bounds.midX / self.previewLayer.bounds.width,
                        y: transformedMetadataObject.bounds.midY / self.previewLayer.bounds.height)
                    
                    let code = QRCode(stringValue: stringValue, relativePosition: point)
                    self.delegate?.cameraController(self, didUpdateQRCode: code)
                }
                else
                {
                    self.delegate?.cameraController(self, didUpdateQRCode: nil)
                }
                
            }
            else if object is AVMetadataFaceObject
            {
                self.delegate?.cameraController(self, didUpdateFaceCount: metadataObjects.count)
            }
        } 
    }
}