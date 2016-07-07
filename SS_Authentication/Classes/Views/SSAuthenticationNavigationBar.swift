//
//  SSAuthenticationNavigationBar.swift
//  SS_Authentication
//
//  Created by Eddie Li on 27/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationNavigationBarDelegate: class {
    func skip();
    func back();
}

class SSAuthenticationNavigationBar: UIView {
    weak var delegate: SSAuthenticationNavigationBarDelegate?;
    
    var skipButton: UIButton?;
    var backButton: SSAuthenticationBackButton?;
    var titleLabel: UILabel?;
    
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
        self.delegate = nil;
    }
    
    // MARK: - Events
    
    func skipButtonAction() {
        self.delegate?.skip();
    }
    
    func backButtonAction() {
        self.delegate?.back();
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true;
        self.setupSubviews();
    }

    // MARK: - Subviews

    private func setupSkipButton() {
        self.skipButton = UIButton(type: .System);
        self.skipButton?.addTarget(self, action: .skipButtonAction, forControlEvents: .TouchUpInside);
    }
    
    private func setupBackButton() {
        self.backButton = SSAuthenticationBackButton(type: .System);
        self.backButton?.color = UIColor.blackColor();
        self.backButton?.addTarget(self, action: .backButtonAction, forControlEvents: .TouchUpInside);
    }
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel();
    }
    
    private func setupSubviews() {
        self.setupSkipButton();
        self.skipButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.skipButton!);
        
        self.setupBackButton();
        self.backButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.backButton!);
        
        self.setupTitleLabel();
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.titleLabel!);
    }
    
    override func updateConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["skip": self.skipButton!,
                         "back": self.backButton!,
                         "title": self.titleLabel!];
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(8)-[back]-(>=0)-[skip]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[title]", options: .DirectionMask, metrics: nil, views: views));

            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[back(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[skip(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[title]", options: .DirectionMask, metrics: nil, views: views));

            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0));
            
            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: self.backButton!, attribute: .CenterY, multiplier: 1.0, constant: 0.0));

            self.hasLoadedConstraints = true;
        }
        super.updateConstraints();
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true;
    }
}

private extension Selector {
    static let skipButtonAction = #selector(SSAuthenticationNavigationBar.skipButtonAction);
    static let backButtonAction = #selector(SSAuthenticationNavigationBar.backButtonAction);
}