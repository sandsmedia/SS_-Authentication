//
//  SSAuthenticationViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationDelegate: class {
    func skip();
    func authenticationGranted(user: SSUser);
}

public class SSAuthenticationViewController: SSAuthenticationBaseViewController, SSAuthenticationLoginDelegate, SSAuthenticationRegisterDelegate {
    public weak var delegate: SSAuthenticationDelegate?;
    public var baseNavigationController: UINavigationController?;
    
    private var buttonsStackView: UIStackView?;
    private var loginButton: UIButton?;
    private var registerButton: UIButton?;
    
    private var hasLoadedConstraints: Bool = false;
    
    // MARK: - Initialisation
    
    convenience public init() {
        self.init(nibName: nil, bundle: nil);
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setup();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setup();
    }
    
    deinit {
        self.delegate = nil;
    }
    
    // MARK: - Implementation of SSAuthenticationLoginDelegate protocols
    
    func loginSuccess(user: SSUser) {
        self.delegate?.authenticationGranted(user);
    }
    
    // MARK: - Implementation of SSAuthenticationRegisterDelegate protocols
    
    func registerSuccess(user: SSUser) {
        self.delegate?.authenticationGranted(user);
    }
    
    // MARK: - Events
    
    func loginButtonAction() {
        let loginViewController = SSAuthenticationLoginViewController.init();
        loginViewController.delegate = self;
        self.navigationController?.pushViewController(loginViewController, animated: true);
    }

    func registerButtonAction() {
        let registerViewController = SSAuthenticationRegisterViewController.init();
        registerViewController.delegate = self;
        self.navigationController?.pushViewController(registerViewController, animated: true);
    }
    
    override func skip() {
        self.delegate?.skip();
    }
    
    // MARK: - Public Methods
    
    override func setup() {
        super.setup();
        
        self.baseNavigationController = UINavigationController.init(rootViewController: self);
        self.baseNavigationController?.navigationBarHidden = true;
    }

    // MARK: - Subviews
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView.init();
        self.buttonsStackView!.axis = .Vertical;
        self.buttonsStackView!.alignment = .Center;
        self.buttonsStackView!.distribution = .EqualCentering;
        self.buttonsStackView?.spacing = 20.0;
    }
    
    private func setupLoginButton() {
        self.loginButton = UIButton.init(type: .System);
        self.loginButton?.setAttributedTitle(NSAttributedString.init(string: "Login", attributes: nil), forState: .Normal);
        self.loginButton?.addTarget(self, action: Selector.loginButtonAction, forControlEvents: .TouchUpInside);
    }
    
    private func setupRegisterButton() {
        self.registerButton = UIButton.init(type: .System);
        self.registerButton?.setAttributedTitle(NSAttributedString.init(string: "Register", attributes: nil), forState: .Normal);
        self.registerButton?.addTarget(self, action: Selector.registerButtonAction, forControlEvents: .TouchUpInside);
    }

    override func setupSubviews() {
        super.setupSubviews();
        
        self.setupButtonsStackView();
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.buttonsStackView!);
        
        self.setupLoginButton();
        self.loginButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.loginButton!);
        
        self.setupRegisterButton();
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.registerButton!);
        
        self.navigationBar?.backButton?.hidden = true;
    }

    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["stack": self.buttonsStackView!,
                         "login": self.loginButton!,
                         "register": self.registerButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[stack]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[stack]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[login]|", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[register]|", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[login(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[register(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }
    
    // MARK: - View lifecycle
    
    override public func loadView() {
        super.loadView();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad();        
    }
}

private extension Selector {
    static let loginButtonAction = #selector(SSAuthenticationViewController.loginButtonAction);
    static let registerButtonAction = #selector(SSAuthenticationViewController.registerButtonAction);
}