//
//  LKHoleView.swift
//  LKQRCode
//
//  Created by LK on 14/12/17.
//  Copyright © 2018 LK. All rights reserved.
//

import UIKit

public enum HoleStyle: Equatable {

    case none
    case blur(style: UIBlurEffectStyle)
    
    public static func ==(lhs: HoleStyle, rhs: HoleStyle) -> Bool {
        switch (lhs, rhs) {
        case (let .blur(a1), let .blur(a2)):
            return a1 == a2
        case (.none,.none):
            return true
        default:
            return false
        }
    }
}

public enum ScanViewSize {
    case fullScreen
    case standard
    case custom(size: CGSize)
}

extension ScanViewSize: RawRepresentable {
    public typealias RawValue = CGSize
    
    public init?(rawValue: CGSize) {
        if rawValue == CGSize.zero {
            self = .fullScreen
        } else {
            return nil
        }
    }
    
    public var rawValue: CGSize {
        switch self {
        case .fullScreen:
            return CGSize.zero

        case .custom(let size):
            return size
            
        case .standard:
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            
            guard height > width else {
                return CGSize(width: 200, height: height - 100)
            }
            return CGSize(width: width - 100, height: 200)
        }
    }
}


public class LKHoleView: UIView {
    
    private(set) var holeRect: CGRect = CGRect.zero
    
    open var holeCornerRadius: CGFloat = 0
    
    //  Blur view not Works on iOS 10 https://forums.developer.apple.com/thread/50854 | Please contribute if you found a better solution
    open var holeStyle: HoleStyle = .none
    
    open var outerColor: UIColor = UIColor.black
    
    open var scanViewSize: ScanViewSize = .standard
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LKHoleView {

    open func createBlurredOuter(style: UIBlurEffectStyle = .extraLight, cornerRadius: CGFloat = 0) {
        holeStyle = .blur(style: style)
        holeCornerRadius = cornerRadius
        createHoleOnView()
        addBlurEffect(style: style)
    }
    
    open func create() {
        switch holeStyle {
        case .none:
            createHoleOnView()
            break
            
        case .blur(let style):
            createHoleOnView()
            addBlurEffect(style: style)
            break
        }
    }
}

private extension LKHoleView {
    
    private func createHoleOnView() {
        
        let maskView = UIView(frame: self.frame)
        maskView.clipsToBounds = true;
        maskView.backgroundColor = UIColor.clear
        
        func holeRect() -> CGRect {
            var holeRect = CGRect(x: 0, y: 0, width: scanViewSize.rawValue.width, height: scanViewSize.rawValue.height)
            let midX = holeRect.midX
            let midY = holeRect.midY
            holeRect.origin.x = maskView.frame.midX - midX
            holeRect.origin.y = maskView.frame.midY - midY
            self.holeRect = holeRect
            return holeRect
        }
        
        let outerbezierPath = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: 0)
        
        let holePath = UIBezierPath(roundedRect: holeRect(), cornerRadius: holeCornerRadius)
        outerbezierPath.append(holePath)
        outerbezierPath.usesEvenOddFillRule = true
        
        let hollowedLayer = CAShapeLayer()
        hollowedLayer.fillRule = kCAFillRuleEvenOdd
        hollowedLayer.fillColor = outerColor.cgColor
        hollowedLayer.path = outerbezierPath.cgPath
        
        if self.holeStyle == .none {
            hollowedLayer.opacity = 0.8
        }
        maskView.layer.addSublayer(hollowedLayer)
        
        switch self.holeStyle {
        case .none:
            self.addSubview(maskView)
            break
            
        case .blur(_):
            self.mask = maskView;
            break
        }
    }
}

internal extension UIView {
    
    /**
     Add and display on current view a blur effect.
     */
    
    @discardableResult
    internal func addBlurEffect(style: UIBlurEffectStyle = .extraLight, atPosition position: Int = -1) -> UIView {
        let blurEffectView = self.createBlurEffect(style: style)
        if position >= 0 {
            self.insertSubview(blurEffectView, at: position)
        } else {
            self.addSubview(blurEffectView)
        }
        return blurEffectView
    }
    
    internal func createBlurEffect(style: UIBlurEffectStyle = .extraLight) -> UIView {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        return blurEffectView
    }
    
}
