
//
//  CIImageExtension.swift
//  LKQRCode
//
//  Created by LK on 18/12/17.
//  Copyright © 2018 LK. All rights reserved.
//

import UIKit

internal extension CIImage {
    
    func nonInterpolatedImage(withScale scale: CGSize) -> UIImage? {
        guard let cgImg =  CIContext().createCGImage(self, from: self.extent) else {
            return nil
        }
        let size = CGSize(width: self.extent.width * scale.width, height: self.extent.height * scale.height)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImg, in: context.boundingBoxOfClipPath)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
        
    }
    
    func scale(forSize size: CGFloat) -> CGSize {
        let scaleX = size / self.extent.size.width
        let scaleY = size / self.extent.size.height
        return CGSize(width: scaleX, height: scaleY)
    }
}
