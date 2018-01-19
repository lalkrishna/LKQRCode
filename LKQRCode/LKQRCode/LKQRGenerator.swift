//
//  LKQRGenerator.swift
//  LKQRCode
//
//  Created by LK on 13/12/17.
//  Copyright © 2018 LK. All rights reserved.
//

import UIKit
import Contacts
import CFNetwork

public typealias QRCode = LKQRCode

public struct LKQRCode {
    
    /**
     L: 7%
     
     M: 15%
     
     Q: 25%
     
     H: 30%
     */
    public enum ErrorCorrectionLevel: String {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }
    
    /**
     Encoded Data that converted to QR Code
     */
    public let data: Data
    
    
    /** Error Correction controls the amount of additional data encoded in the output image to provide error correction.
     Higher levels of error correction result in larger output images but allow larger areas of the code to be damaged or
     obscured without. There are four possible correction modes. Default Value is low.
     */
    public var errorCorrection = ErrorCorrectionLevel.low
    
    
    /**
     *  QRCode Color
     */
    public var color: CIColor?
    
    
    /**
     *  QRCode Background Color
     */
    public var backgroundColor: CIColor?
    
    
    /**
     *  QRCode Size which defines Square dimention. Default value is 200
     */
    public var size: CGFloat = 200
    
    
}

// MARK: - Protocol

protocol QRCodeProtocol {
    init(_ data: Data)
    init?(_ string: String)
    init?(_ contact: CNContact)
    init?(_ wifi: WiFi)
}

// MARK: - Init

extension LKQRCode: QRCodeProtocol {
    
    public init(_ data: Data) {
        self.data = data
    }
    
    public init?(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        self.data = data
    }
    
    public init?(_ wifi: WiFi) {
        self.init(wifi.desciption)
    }
    
    public init?(_ contact: CNContact) {
        guard let data = contact.vcardData() else { return nil }
        self.data = data
    }
    
}

// MARK: - QR Generate

extension LKQRCode {
    
    public var image: UIImage? {

        guard let ciImage = ciImage else {
            return nil
        }
        let size = ciImage.scale(forSize: self.size)
        let qrImage = ciImage.nonInterpolatedImage(withScale: size)
        return qrImage
    }
    
    
    private var ciImage: CIImage? {
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(self.data, forKey: "inputMessage")
        filter?.setValue(self.errorCorrection.rawValue, forKey: "inputCorrectionLevel")
        
        guard (color != nil) || (backgroundColor != nil) else {
            return filter?.outputImage
        }
        
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setDefaults()
        colorFilter.setValue(filter?.outputImage, forKey: "inputImage")
        colorFilter.setValue(color ?? Color.black, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor ?? Color.white, forKey: "inputColor1")
        
        return colorFilter.outputImage;
    }
}

struct Color {
    static let black = CIColor(color: UIColor.black)
    static let white = CIColor(color: UIColor.white)
}

// MARK: - Decode Data

extension LKQRCode {
    
    var contact: CNContact? {
        return self.data.contact
    }
}




