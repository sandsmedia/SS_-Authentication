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
    func authenticationGranted(_ user: SSUser)
}

open class SSAuthenticationViewController: SSAuthenticationBaseViewController, SSAuthenticationLoginDelegate, SSAuthenticationRegisterDelegate, SSAuthenticationUpdateDelegate {
    open weak var delegate: SSAuthenticationDelegate?
    open var baseNavigationController: UINavigationController?
    
    fileprivate var buttonsStackView: UIStackView?
    fileprivate var loginButton: UIButton?
    fileprivate var registerButton: UIButton?
    fileprivate var updateEmailButton: UIButton?
    fileprivate var updatePasswordButton: UIButton?
    
    fileprivate var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience public init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    open func loginSuccess(_ user: SSUser) {
        self.delegate?.authenticationGranted(user)
    }
    
    // MARK: - Implementation of SSAuthenticationRegisterDelegate protocols
    
    open func registerSuccess(_ user: SSUser) {
        self.delegate?.authenticationGranted(user)
    }
    
    // MARK: - Implemetation of SSAuthenticationUpdateDelegate protocols
    
    open func updateSuccess() {
        
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
        self.baseNavigationController?.isNavigationBarHidden = true
    }

    // MARK: - Subviews
    
    fileprivate func setupButtonsStackView() {
        self.buttonsStackView = UIStackView()
        self.buttonsStackView!.axis = .vertical
        self.buttonsStackView!.alignment = .center
        self.buttonsStackView!.distribution = .equalCentering
        self.buttonsStackView?.spacing = 10.0
    }
    
    fileprivate func setupLoginButton() {
        self.loginButton = UIButton(type: .system)
        self.loginButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.login"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.loginButton?.addTarget(self, action: .loginButtonAction, for: .touchUpInside)
        self.loginButton?.layer.borderWidth = 1.0
        self.loginButton?.layer.borderColor = UIColor.black.cgColor
    }
    
    fileprivate func setupRegisterButton() {
        self.registerButton = UIButton(type: .system)
        self.registerButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.registerButton?.addTarget(self, action: .registerButtonAction, for: .touchUpInside)
        self.registerButton?.layer.borderWidth = 1.0
        self.registerButton?.layer.borderColor = UIColor.black.cgColor
    }
    
    fileprivate func setupUpdateEmailButton() {
        self.updateEmailButton = UIButton(type: .system)
        self.updateEmailButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.updateEmail"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.updateEmailButton?.addTarget(self, action: .updateEmailButtonAction, for: .touchUpInside)
        self.updateEmailButton?.layer.borderWidth = 1.0
        self.updateEmailButton?.layer.borderColor = UIColor.black.cgColor
    }

    fileprivate func setupUpdatePasswordButton() {
        self.updatePasswordButton = UIButton(type: .system)
        self.updatePasswordButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.updatePassword"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.updatePasswordButton?.addTarget(self, action: .updatePasswordButtonAction, for: .touchUpInside)
        self.updatePasswordButton?.layer.borderWidth = 1.0
        self.updatePasswordButton?.layer.borderColor = UIColor.black.cgColor
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
    }

    override open func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["stack": self.buttonsStackView!,
                                        "login": self.loginButton!,
                                        "register": self.registerButton!,
                                        "email": self.updateEmailButton!,
                                        "password": self.updatePasswordButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT]

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[stack]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[stack]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[login]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[register]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[login(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[register(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[email(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[password(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - View lifecycle
    
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidLoad() {
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
