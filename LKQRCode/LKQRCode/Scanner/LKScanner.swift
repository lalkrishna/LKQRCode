//
//  LKScanner.swift
//  FindMyTrain
//
//  Created by LK on 12/12/17.
//  Copyright © 2017 LK. All rights reserved.
//

import UIKit
import AVKit

extension UIViewController {
    
    func requestPermission(completionHandler: @escaping (Bool) -> () ) {
        let authorizationStat = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch authorizationStat {
        case AVAuthorizationStatus.authorized:
            print("Authorized")
            completionHandler(true)
            
        case .denied:
            print("Denied")
            completionHandler(false)
            
        case .restricted:
            print("restricted")
            completionHandler(false)
            
        case .notDetermined:
            print("Not Determined")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granded) in
                completionHandler(granded)
            })
        }
    }
}

public enum ScanError: Error {
    
    /*
     AVCaptureDevice authorization failed.
     */
    case deviceAuthorizationFailed
    
    /*
     Unable to get Capture Device input
     */
    case deviceNotFound
    
    /*
     Failed to add video input to the Capture session
     */
    case videoInputFailed
    
    /*
     Failed to add Meta data output to capture session. Screen willn't detect QR/Barcode Objects
     */
    case metaDataOutputFailed
    
}

extension ScanError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deviceAuthorizationFailed:
            return NSLocalizedString("Camera using permission denied", comment: "Permission")
            
        case .deviceNotFound:
            return NSLocalizedString("Device Not Found", comment: "No Device")
            
        case .metaDataOutputFailed:
            return NSLocalizedString("Failed to create MetaData Output", comment: "MetaDataOutput")
            
        case .videoInputFailed:
            return NSLocalizedString("Failed to Video Input", comment: "VideoInput")
        }
    }
}

public protocol LKScanDelegate {
    func scanner(_ scanner: LKScanner, scannedText: String)
    func scannerDidFail(_ scanner: LKScanner, error: ScanError)
}

internal protocol ScannerProtocol {
    func start()
    func resume()
    func pause()
    func setDefaultHole()
}


public typealias QRScanner = LKScanner

public class LKScanner: UIViewController {
    
    var captureSession: AVCaptureSession? = nil
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    open var holeView: LKHoleView?
    
    open var topView: UIView?
    
    open var delegate: LKScanDelegate?
    
    open var isReading = false
    
    override public func loadView() {
        let customView = UIView(frame: UIScreen.main.bounds)
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = customView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        if (topView != nil) {
            view.addSubview(topView!)
//            topView?.layer.zPosition = 1;
        }
        
        requestPermission { (granded) in
            if granded {
                DispatchQueue.main.async {
                    self.start()
                }
            } else {
                self.delegate?.scannerDidFail(self, error: .deviceAuthorizationFailed)
            }
        }
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- LKScanner Extensions

extension LKScanner: ScannerProtocol {
    
    public func setDefaultHole() {
        let holeView = LKHoleView()
        holeView.holeCornerRadius = 8.0
        holeView.create()
        self.holeView = holeView
    }
    
    public func resume() {
        
        guard (captureSession != nil) else {
            return
        }
        captureSession?.startRunning()
        isReading = true
    }
    
    public func pause() {
        
        guard (captureSession != nil) else {
            return
        }
        captureSession?.stopRunning()
        isReading = false
    }
    
    
    public func start() {
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        let videoInput: AVCaptureInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            self.delegate?.scannerDidFail(self, error: .deviceNotFound)
            return
        }
        
        captureSession = AVCaptureSession()
        if (captureSession?.canAddInput(videoInput))! {
            captureSession?.addInput(videoInput)
        } else {
            self.delegate?.scannerDidFail(self, error: .videoInputFailed)
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        if (captureSession?.canAddOutput(metaDataOutput))! {
            captureSession?.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.qr]
            //            metaDataOutput.metadataObjectTypes = [.qr, .pdf417, .aztec, .code128, .ean8, .ean13, .upce, .code39, .code93] // QR & BarCode support
        } else {
            self.delegate?.scannerDidFail(self, error: .metaDataOutputFailed)
            return
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession!)
        layer.frame = view.layer.bounds
        layer.videoGravity = .resizeAspectFill
        layer.setOrientationForCurrentState()
        videoPreviewLayer = layer
        
        view.layer.addSublayer(layer)
        
        captureSession?.startRunning()
        isReading = true
        
        if let hole = self.holeView, hole.holeRect != CGRect.zero {
            view.addSubview(hole)
            let visibleRect = layer.metadataOutputRectConverted(fromLayerRect: hole.holeRect)
            metaDataOutput.rectOfInterest = visibleRect
        }
        if (topView != nil) {
            view.bringSubview(toFront: topView!)
        }
    }
}


extension LKScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObj = metadataObjects.first else {
            print("No Metadata objects")
            return
        }
        let readableObject = metadataObj as! AVMetadataMachineReadableCodeObject
        if let value = readableObject.stringValue {
            
            print("OBJ TYPE: \(readableObject.type), VALUE READ: \n\(value)")
            detectType(string: value)
            self.delegate?.scanner(self, scannedText: value)
        }
    }
    
    func detectType(string: String) {
        
        if string.hasPrefix("SMSTO:") {
            print("Content Tpye: SMS")
        }
        
        if string.hasPrefix("BEGIN:VCARD") {
            print("Content Tpye: VCARD")
        }
        
        if string.hasPrefix("tel:") {
            print("Content Tpye: TEL")
        }
        
        if string.hasPrefix("tel:") {
            print("Content Tpye: TEL")
        }
        
        if string.hasPrefix("MATMSG:TO:") {
            print("Content Tpye: EMAIL")
        }
    }
    
}

