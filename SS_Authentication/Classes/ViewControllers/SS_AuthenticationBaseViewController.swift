//
//  SS_AuthenticationBaseViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public class SS_AuthenticationBaseViewController: UIViewController {
    private var loadingView: SS_AuthenticationLoadingView?;
    
    public var hideStatusBar: Bool = false;
    
    private var hasLoadedConstraints: Bool = false;

    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setup();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setup();
    }
    
    deinit {

    }
    
    // MARK: - Public Methods
    
    func setup() {
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    // MARK: - Subviews
    
    private func setupLoadingView() {
        self.loadingView = SS_AuthenticationLoadingView.init();
    }
    
    func setupSubviews() {
        self.setupLoadingView();
        self.loadingView!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.loadingView!);
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar;
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["loading": self.loadingView!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[loading]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loading]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraint(NSLayoutConstraint.init(item: self.loadingView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0));

            self.view.addConstraint(NSLayoutConstraint.init(item: self.loadingView!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0));

            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }

    // MARK: - View lifecycle
    
    override public func loadView() {
        self.view = UIView.init();
        self.view.backgroundColor = UIColor.whiteColor();
        self.view.translatesAutoresizingMaskIntoConstraints = true;
        
        self.setupSubviews();
        self.updateViewConstraints();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
