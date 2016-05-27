//
//  SSAuthenticationBaseViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public class SSAuthenticationBaseViewController: UIViewController, SSAuthenticationNavigationBarDelegate {
    var navigationBar: SSAuthenticationNavigationBar?;
    private var loadingView: SSAuthenticationLoadingView?;
    
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
    
    // MARK: - Implementation of SSAuthenticationNavigationBarDelegate protocols
    
    func skip() {
        
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    // MARK: - Public Methods
    
    func setup() {
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    func showLoadingView() {
        self.view.bringSubviewToFront(self.loadingView!);
        UIView.animateWithDuration(0.3) { 
            self.loadingView?.alpha = 1.0;
        }
    }
    
    func hideLoadingView() {
        UIView.animateWithDuration(0.3) {
            self.loadingView?.alpha = 0.0;
        }
    }
    
    // MARK: - Subviews
    
    private func setupNavigationBar() {
        self.navigationBar = SSAuthenticationNavigationBar.init();
        self.navigationBar?.delegate = self;
        self.navigationBar?.backgroundColor = UIColor.yellowColor();
    }
    
    private func setupLoadingView() {
        self.loadingView = SSAuthenticationLoadingView.init();
        self.loadingView?.alpha = 0.0;
    }
    
    func setupSubviews() {
        self.setupLoadingView();
        self.loadingView!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.loadingView!);
        
        self.setupNavigationBar();
        self.navigationBar?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.navigationBar!);
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar;
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["loading": self.loadingView!,
                         "bar": self.navigationBar!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[loading]", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bar]|", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loading]", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(64)]", options: .DirectionMask, metrics: nil, views: views));

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
