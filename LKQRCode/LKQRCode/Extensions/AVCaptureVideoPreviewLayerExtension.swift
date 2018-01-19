//
//  AVCaptureVideoPreviewLayerExtension.swift
//  LKQRCode
//
//  Created by LK on 17/01/18.
//  Copyright © 2018 LK. All rights reserved.
//

import Foundation
import AVKit

extension AVCaptureVideoPreviewLayer {
    func setOrientationForCurrentState() {
        
        guard let connection = self.connection, connection.isVideoOrientationSupported else {
            return
        }
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        switch (orientation) {
        case .portrait:
            connection.videoOrientation = .portrait
            break
            
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
            break
            
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
            break
            
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
            break
            
        default:
            connection.videoOrientation = .portrait
            break
        }
    }
}
