//
//  SSAuthenticationBackButton.swift
//  SS_Authentication
//
//  Created by Eddie Li on 02/06/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public enum ArrowDirection : Int {
    case Left
    case Right
}

class SSAuthenticationBackButton: UIButton {
    var color = UIColor.whiteColor()
    var hightlightColor = UIColor.lightGrayColor()
    var lineWidth: CGFloat = 3.0
    var lineCap: CGLineCap = .Square
    var verticalInset: CGFloat = 13.0
    var arrowDirection: ArrowDirection = .Left
    
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
    
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.hidden = false
        self.opaque = false
        self.clipsToBounds = false
        self.clearsContextBeforeDrawing = true
    }

    // MARK: - Custom Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let height = rect.height - 2.0 * self.verticalInset
        let width = height / 2.0
        
        if (width >= rect.width) {
            print("Arrow %@ is too wide for bounding rect - clipping will occur", self)
        }
        
        let pathStart = lineWidth
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, self.lineCap)
        if (self.state == .Highlighted) {
            CGContextSetStrokeColorWithColor(context, self.hightlightColor.CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, self.color.CGColor)
        }
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
        CGContextSetLineWidth(context, self.lineWidth)
        if (self.arrowDirection == .Right) {
            CGContextMoveToPoint(context, pathStart, self.verticalInset)
            CGContextAddLineToPoint(context, pathStart + width, self.bounds.size.height / 2.0)
            CGContextAddLineToPoint(context, pathStart, self.bounds.size.height - self.verticalInset)
        } else {
            CGContextMoveToPoint(context, pathStart + width, self.verticalInset)
            CGContextAddLineToPoint(context, pathStart, self.bounds.size.height / 2.0)
            CGContextAddLineToPoint(context, pathStart + width, self.bounds.size.height - self.verticalInset)
        }
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
}