//
//  SS_AuthenticationLoadingView.swift
//  SS_Authentication
//
//  Created by Eddie Li on 26/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

let LOADING_RADIUS = CGFloat.init(5.0);

class SS_AuthenticationLoadingView: UIView {
    private var loadingStackView: UIStackView?;
    private var dotOne: UIImageView?;
    private var dotTwo: UIImageView?;
    private var dotThree: UIImageView?;
    
    private var hasLoadedConstraints: Bool = false;
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector.applicationDidBecomeActive, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func startAnimation() {
        self.dotOne!.transform = CGAffineTransformMakeScale(0.01, 0.01)
        self.dotTwo!.transform = CGAffineTransformMakeScale(0.01, 0.01)
        self.dotThree!.transform = CGAffineTransformMakeScale(0.01, 0.01)
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.dotOne!.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.2, options: [.Repeat, .Autoreverse], animations: {
            self.dotTwo!.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.4, options: [.Repeat, .Autoreverse], animations: {
            self.dotThree!.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    // MARK: - Subviews
    
    private func setupLoadingStackView() {
        self.loadingStackView = UIStackView.init();
        self.loadingStackView!.axis = .Horizontal;
        self.loadingStackView!.alignment = .Center;
        self.loadingStackView!.distribution = .EqualCentering;
        self.loadingStackView?.spacing = LOADING_RADIUS;
    }
    
    private func setupDotOne() {
        self.dotOne = UIImageView.init();
        self.dotOne?.backgroundColor = UIColor.grayColor();
        self.dotOne?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupDotTwo() {
        self.dotTwo = UIImageView.init();
        self.dotTwo?.backgroundColor = UIColor.grayColor();
        self.dotTwo?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupDotThree() {
        self.dotThree = UIImageView.init();
        self.dotThree?.backgroundColor = UIColor.grayColor();
        self.dotThree?.layer.cornerRadius = LOADING_RADIUS;
    }
    
    private func setupSubviews() {
        self.setupLoadingStackView();
        self.loadingStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.loadingStackView!);
        
        self.setupDotOne();
        self.dotOne?.translatesAutoresizingMaskIntoConstraints = false;
        self.loadingStackView?.addArrangedSubview(self.dotOne!);
        
        self.setupDotTwo();
        self.dotTwo?.translatesAutoresizingMaskIntoConstraints = false;
        self.loadingStackView?.addArrangedSubview(self.dotTwo!);
        
        self.setupDotThree();
        self.dotThree?.translatesAutoresizingMaskIntoConstraints = false;
        self.loadingStackView?.addArrangedSubview(self.dotThree!);
    }
    
    override func updateConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["stack": self.loadingStackView!,
                         "dotOne": self.dotOne!,
                         "dotTwo": self.dotTwo!,
                         "dotThree": self.dotThree!];
            
            let metrics = ["DIAMETER": LOADING_RADIUS * 2];
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[stack]", options: .DirectionMask, metrics: nil, views: views));
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[stack]", options: .DirectionMask, metrics: nil, views: views));
            
            self.addConstraint(NSLayoutConstraint.init(item: self.loadingStackView!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0));
            
            self.addConstraint(NSLayoutConstraint.init(item: self.loadingStackView!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotOne(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotTwo(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[dotThree(DIAMETER)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotOne(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotTwo(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.loadingStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dotThree(DIAMETER)]|", options: .DirectionMask, metrics: metrics, views: views));
            
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
    static let applicationDidBecomeActive = #selector(SS_AuthenticationLoadingView.applicationDidBecomeActive);
}