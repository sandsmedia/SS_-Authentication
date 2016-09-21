//
//  SSAuthenticationBackButton.swift
//  SS_Authentication
//
//  Created by Eddie Li on 02/06/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public enum ArrowDirection: Int {
    case left
    case right
}

class SSAuthenticationBackButton: UIButton {
    var color = UIColor.white
    var hightlightColor = UIColor.lightGray
    var lineWidth: CGFloat = 3.0
    var lineCap: CGLineCap = .square
    var verticalInset: CGFloat = 13.0
    var arrowDirection: ArrowDirection = .left
    
    // MARK: - Initialisation
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    convenience init(type buttonType: UIButtonType) {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {

    }

    // MARK: - Private Methods
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.isHidden = false
        self.isOpaque = false
        self.clipsToBounds = false
        self.clearsContextBeforeDrawing = true
    }

    // MARK: - Custom Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let height = rect.height - 2.0 * self.verticalInset
        let width = height / 2.0
        
        if (width >= rect.width) {
            print("Arrow %@ is too wide for bounding rect - clipping will occur", self)
        }
        
        let pathStart = lineWidth
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        context?.setLineCap(self.lineCap)
        if (self.state == .highlighted) {
            context?.setStrokeColor(self.hightlightColor.cgColor)
        } else {
            context?.setStrokeColor(self.color.cgColor)
        }
        context?.setAllowsAntialiasing(true)
        context?.setShouldAntialias(true)
        context?.setLineWidth(self.lineWidth)
        if (self.arrowDirection == .right) {
            context?.move(to: CGPoint(x: pathStart, y: self.verticalInset))
            context?.addLine(to: CGPoint(x: pathStart + width, y: self.bounds.size.height / 2.0))
            context?.addLine(to: CGPoint(x: pathStart, y: self.bounds.size.height - self.verticalInset))
        } else {
            context?.move(to: CGPoint(x: pathStart + width, y: self.verticalInset))
            context?.addLine(to: CGPoint(x: pathStart, y: self.bounds.size.height / 2.0))
            context?.addLine(to: CGPoint(x: pathStart + width, y: self.bounds.size.height - self.verticalInset))
        }
        context?.strokePath()
        context?.restoreGState()
    }
}
