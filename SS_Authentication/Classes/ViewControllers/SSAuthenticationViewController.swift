//
//  SSAuthenticationViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationDelegate: class {
    func skip()
    func authenticationGranted(user: SSUser)
}

public class SSAuthenticationViewController: SSAuthenticationBaseViewController, SSAuthenticationLoginDelegate, SSAuthenticationRegisterDelegate, SSAuthenticationUpdateDelegate {
    public weak var delegate: SSAuthenticationDelegate?
    public var baseNavigationController: UINavigationController?
    
    private var buttonsStackView: UIStackView?
    private var loginButton: UIButton?
    private var registerButton: UIButton?
    private var updateEmailButton: UIButton?
    private var updatePasswordButton: UIButton?
    
    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience public init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    deinit {
        self.delegate = nil
    }
    
    // MARK: - Implementation of SSAuthenticationLoginDelegate protocols
    
    public func loginSuccess(user: SSUser) {
        self.delegate?.authenticationGranted(user)
    }
    
    // MARK: - Implementation of SSAuthenticationRegisterDelegate protocols
    
    public func registerSuccess(user: SSUser) {
        self.delegate?.authenticationGranted(user)
    }
    
    // MARK: - Implemetation of SSAuthenticationUpdateDelegate protocols
    
    public func updateSuccess() {
        
    }
    
    // MARK: - Events
    
    func loginButtonAction() {
        let loginViewController = SSAuthenticationLoginViewController()
        loginViewController.delegate = self
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

    func registerButtonAction() {
        let registerViewController = SSAuthenticationRegisterViewController()
        registerViewController.delegate = self
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    func updateEmailButtonAction() {
        let updateViewController = SSAuthenticationUpdateViewController()
        updateViewController.delegate = self
        updateViewController.isUpdateEmail = true
        self.navigationController?.pushViewController(updateViewController, animated: true)
    }
    
    func updatePasswordButtonAction() {
        let updateViewController = SSAuthenticationUpdateViewController()
        updateViewController.delegate = self
        updateViewController.isUpdateEmail = false
        self.navigationController?.pushViewController(updateViewController, animated: true)
    }
    
    override func skip() {
        self.delegate?.skip()
    }
    
    // MARK: - Public Methods
    
    override func setup() {
        super.setup()
        
        self.baseNavigationController = UINavigationController(rootViewController: self)
        self.baseNavigationController?.navigationBarHidden = true
    }

    // MARK: - Subviews
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView()
        self.buttonsStackView!.axis = .Vertical
        self.buttonsStackView!.alignment = .Center
        self.buttonsStackView!.distribution = .EqualCentering
        self.buttonsStackView?.spacing = 10.0
    }
    
    private func setupLoginButton() {
        self.loginButton = UIButton(type: .System)
        self.loginButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.login"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal)
        self.loginButton?.addTarget(self, action: .loginButtonAction, forControlEvents: .TouchUpInside)
        self.loginButton?.layer.borderWidth = 1.0
        self.loginButton?.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    private func setupRegisterButton() {
        self.registerButton = UIButton(type: .System)
        self.registerButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal)
        self.registerButton?.addTarget(self, action: .registerButtonAction, forControlEvents: .TouchUpInside)
        self.registerButton?.layer.borderWidth = 1.0
        self.registerButton?.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    private func setupUpdateEmailButton() {
        self.updateEmailButton = UIButton(type: .System)
        self.updateEmailButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.updateEmail"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal)
        self.updateEmailButton?.addTarget(self, action: .updateEmailButtonAction, forControlEvents: .TouchUpInside)
        self.updateEmailButton?.layer.borderWidth = 1.0
        self.updateEmailButton?.layer.borderColor = UIColor.blackColor().CGColor
    }

    private func setupUpdatePasswordButton() {
        self.updatePasswordButton = UIButton(type: .System)
        self.updatePasswordButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.updatePassword"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal)
        self.updatePasswordButton?.addTarget(self, action: .updatePasswordButtonAction, forControlEvents: .TouchUpInside)
        self.updatePasswordButton?.layer.borderWidth = 1.0
        self.updatePasswordButton?.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.buttonsStackView!)
        
        self.setupLoginButton()
        self.loginButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.loginButton!)
        
        self.setupRegisterButton()
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.registerButton!)
        
        self.setupUpdateEmailButton()
        self.updateEmailButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.updateEmailButton!)

        self.setupUpdatePasswordButton()
        self.updatePasswordButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.updatePasswordButton!)

        self.navigationBar?.backButton?.hidden = true
    }

    override public func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["stack": self.buttonsStackView!,
                         "login": self.loginButton!,
                         "register": self.registerButton!,
                         "email": self.updateEmailButton!,
                         "password": self.updatePasswordButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "XLARGE_SPACING": NAVIGATION_BAR_HEIGHT + GENERAL_SPACING]

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[stack]|", options: .DirectionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[stack]-(SPACING)-|", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[login]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[register]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[login(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[register(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views))

            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - View lifecycle
    
    override public func loadView() {
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if (SSAuthenticationManager.sharedInstance.accessToken == nil) {
            self.buttonsStackView?.removeArrangedSubview(self.updateEmailButton!)
            self.updateEmailButton?.removeFromSuperview()
            self.buttonsStackView?.removeArrangedSubview(self.updatePasswordButton!)
            self.updatePasswordButton?.removeFromSuperview()
        } else {
            self.buttonsStackView?.removeArrangedSubview(self.loginButton!)
            self.loginButton?.removeFromSuperview()
            self.buttonsStackView?.removeArrangedSubview(self.registerButton!)
            self.registerButton?.removeFromSuperview()
        }
    }
}

private extension Selector {
    static let loginButtonAction = #selector(SSAuthenticationViewController.loginButtonAction)
    static let registerButtonAction = #selector(SSAuthenticationViewController.registerButtonAction)
    static let updateEmailButtonAction = #selector(SSAuthenticationViewController.updateEmailButtonAction)
    static let updatePasswordButtonAction = #selector(SSAuthenticationViewController.updatePasswordButtonAction)
}