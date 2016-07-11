//
//  SSAuthenticationLoadingView.swift
//  SS_Authentication
//
//  Created by Eddie Li on 26/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

class SSAuthenticationLoadingView: UIView {
    private var dotsStackView: UIStackView?;
    private var dotOne: UIImageView?;
    private var dotTwo: UIImageView?;
    private var dotThree: UIImageView?;
    
    private var hasLoadedConstraints = false;
    
    // MARK: - Initialisation
    convenience init() {
        self.init(frame: CGRect.zero);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setup();
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Events
    
    func applicationDidBecomeActive(notification: NSNotification) {
        startAnimation();
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true;
        self.setupSubviews();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .applicationDidBecomeActive, name: UIApplicationDidBecomeActiveNotification, object: nil);
    }
    
    private func startAnimation() {
        self.dotOne!.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.dotTwo!.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.dotThree!.transform = CGAffineTransformMakeScale(0.01, 0.01);
        
        UIView.animateWithDuration((2 * ANIMATION_DURATION), delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.dotOne!.transform = CGAffineTransformIdentity;
            }, completion: nil);
        
        UIView.animateWithDuration((2 * ANIMATION_DURATION), delay: 0.2, options: [.Repeat, .Autoreverse], animations: {
            self.dotTwo!.transform = CGAffineTransformIdentity;
            }, completion: nil);
        
        UIView.animateWithDuration((2 * ANIMATION_DURATION), delay: 0.4, options: [.Repeat, .Autoreverse], animations: {
            self.dotThree!.transform = CGAffineTransformIdentity;
            }, completion: nil);
    }
    
    // MARK: - Subviews
    
    private func setupDotsStackView() {
        self.dotsStackView = UIStackView();
        self.dotsStackView!.axis = .Horizontal;
        self.dotsStackView!.alignment = .Center;
        self.dotsStackView!.distribution = .EqualCentering;
        self.dotsStackView?.spacing = LOADING_RADIUS;
    }
    
    private func setupDotOne() {
        self.dotOne = UIImageView();
        self.dotOne?.backgroundColor = UIColor.grayColor();
        self.dotOne?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupDotTwo() {
        self.dotTwo = UIImageView();
        self.dotTwo?.backgroundColor = UIColor.grayColor();
        self.dotTwo?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupDotThree() {
        self.dotThree = UIImageView();
        self.dotThree?.backgroundColor = UIColor.grayColor();
        self.dotThree?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupSubviews() {
        self.setupDotsStackView();
        self.dotsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.dotsStackView!);
        
        self.setupDotOne();
        self.dotOne?.translatesAutoresizingMaskIntoConstraints = false;
        self.dotsStackView?.addArrangedSubview(self.dotOne!);
        
        self.setupDotTwo();
        self.dotTwo?.translatesAutoresizingMaskIntoConstraints = false;
        self.dotsStackView?.addArrangedSubview(self.dotTwo!);
        
        self.setupDotThree();
        self.dotThree?.translatesAutoresizingMaskIntoConstraints = false;
        self.dotsStackView?.addArrangedSubview(self.dotThree!);
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["stack": self.dotsStackView!,
                         "dotOne": self.dotOne!,
                         "dotTwo": self.dotTwo!,
                         "dotThree": self.dotThree!];
            
            let metrics = ["DIAMETER": LOADING_DIAMETER];
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[stack]", options: .DirectionMask, metrics: nil, views: views));
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[stack]", options: .DirectionMask, metrics: nil, views: views));
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0));
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotOne(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotTwo(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotThree(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotOne(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotTwo(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotThree(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.hasLoadedConstraints = true;
        }
        super.updateConstraints();
        
        self.startAnimation();
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true;
    }
}

private extension Selector {
    static let applicationDidBecomeActive = #selector(SSAuthenticationLoadingView.applicationDidBecomeActive);
}