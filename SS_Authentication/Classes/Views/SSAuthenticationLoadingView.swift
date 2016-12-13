//
//  SSAuthenticationLoadingView.swift
//  SS_Authentication
//
//  Created by Eddie Li on 26/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

class SSAuthenticationLoadingView: UIView {
    fileprivate var dotsStackView: UIStackView?
    fileprivate var dotOne: UIImageView?
    fileprivate var dotTwo: UIImageView?
    fileprivate var dotThree: UIImageView?
    
    fileprivate var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    convenience init() {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Events
    
    func applicationDidBecomeActive(_ notification: Notification) {
        startAnimation()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
        
        NotificationCenter.default.addObserver(self, selector: .applicationDidBecomeActive, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func startAnimation() {
        self.dotOne!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.dotTwo!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.dotThree!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: (2 * ANIMATION_DURATION), delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.dotOne!.transform = CGAffineTransform.identity
            }, completion: nil)
        
        UIView.animate(withDuration: (2 * ANIMATION_DURATION), delay: 0.2, options: [.repeat, .autoreverse], animations: {
            self.dotTwo!.transform = CGAffineTransform.identity
            }, completion: nil)
        
        UIView.animate(withDuration: (2 * ANIMATION_DURATION), delay: 0.4, options: [.repeat, .autoreverse], animations: {
            self.dotThree!.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    // MARK: - Subviews
    
    fileprivate func setupDotsStackView() {
        self.dotsStackView = UIStackView()
        self.dotsStackView?.axis = .horizontal
        self.dotsStackView?.alignment = .center
        self.dotsStackView?.distribution = .equalCentering
        self.dotsStackView?.spacing = LOADING_RADIUS
    }
    
    fileprivate func setupDotOne() {
        self.dotOne = UIImageView()
        self.dotOne?.backgroundColor = SSAuthenticationManager.sharedInstance.loadingViewColour
        self.dotOne?.layer.cornerRadius = LOADING_RADIUS
    }
    
    fileprivate func setupDotTwo() {
        self.dotTwo = UIImageView()
        self.dotTwo?.backgroundColor = SSAuthenticationManager.sharedInstance.loadingViewColour
        self.dotTwo?.layer.cornerRadius = LOADING_RADIUS
    }
    
    fileprivate func setupDotThree() {
        self.dotThree = UIImageView()
        self.dotThree?.backgroundColor = SSAuthenticationManager.sharedInstance.loadingViewColour
        self.dotThree?.layer.cornerRadius = LOADING_RADIUS
    }
    
    fileprivate func setupSubviews() {
        self.setupDotsStackView()
        self.dotsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.dotsStackView!)
        
        self.setupDotOne()
        self.dotOne?.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView?.addArrangedSubview(self.dotOne!)
        
        self.setupDotTwo()
        self.dotTwo?.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView?.addArrangedSubview(self.dotTwo!)
        
        self.setupDotThree()
        self.dotThree?.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView?.addArrangedSubview(self.dotThree!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["stack": self.dotsStackView!,
                                        "dotOne": self.dotOne!,
                                        "dotTwo": self.dotTwo!,
                                        "dotThree": self.dotThree!]
            
            let metrics = ["DIAMETER": LOADING_DIAMETER]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[stack]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[stack]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotOne(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotTwo(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotThree(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotOne(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotTwo(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotThree(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
        
        self.startAnimation()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let applicationDidBecomeActive = #selector(SSAuthenticationLoadingView.applicationDidBecomeActive)
}
