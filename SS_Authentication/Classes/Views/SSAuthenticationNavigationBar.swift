//
//  SSAuthenticationNavigationBar.swift
//  SS_Authentication
//
//  Created by Eddie Li on 27/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationNavigationBarDelegate: class {
    func skip()
    func back()
}

class SSAuthenticationNavigationBar: UIView {
    weak var delegate: SSAuthenticationNavigationBarDelegate?
    
    var skipButton: UIButton?
    var backButton: SSAuthenticationBackButton?
    var titleLabel: UILabel?
    
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
        self.delegate = nil
    }
    
    // MARK: - Events
    
    func skipButtonAction() {
        self.delegate?.skip()
    }
    
    func backButtonAction() {
        self.delegate?.back()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
    }

    // MARK: - Subviews

    fileprivate func setupSkipButton() {
        self.skipButton = UIButton(type: .system)
        self.skipButton?.addTarget(self, action: .skipButtonAction, for: .touchUpInside)
    }
    
    fileprivate func setupBackButton() {
        self.backButton = SSAuthenticationBackButton(type: .system)
        self.backButton?.color = UIColor.white
        self.backButton?.addTarget(self, action: .backButtonAction, for: .touchUpInside)
    }
    
    fileprivate func setupTitleLabel() {
        self.titleLabel = UILabel()
    }
    
    fileprivate func setupSubviews() {
        self.setupSkipButton()
        self.skipButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.skipButton!)
        
        self.setupBackButton()
        self.backButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backButton!)
        
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["skip": self.skipButton!,
                         "back": self.backButton!,
                         "title": self.titleLabel!] as [String : Any]
            
            let metrics = ["SPACING": GENERAL_SPACING - 2.0,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT]

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[back]-(>=0)-[skip]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[title]", options: .directionMask, metrics: nil, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(LARGE_SPACING)-[back(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(LARGE_SPACING)-[skip(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[title]", options: .directionMask, metrics: nil, views: views))

            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .centerY, relatedBy: .equal, toItem: self.backButton!, attribute: .centerY, multiplier: 1.0, constant: 0.0))

            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let skipButtonAction = #selector(SSAuthenticationNavigationBar.skipButtonAction)
    static let backButtonAction = #selector(SSAuthenticationNavigationBar.backButtonAction)
}
