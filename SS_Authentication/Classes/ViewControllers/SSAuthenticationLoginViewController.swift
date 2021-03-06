//
//  SSAuthenticationLoginViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationLoginDelegate: class {
    func loginSuccess(_ user: SSUser)
}

open class SSAuthenticationLoginViewController: SSAuthenticationBaseViewController, SSAuthenticationResetDelegate {
    open weak var delegate: SSAuthenticationLoginDelegate?
    
    fileprivate var loginButton: UIButton?
    fileprivate var resetButton: UIButton?
    
    fileprivate var hasLoadedConstraints = false

    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    // MARK: - Accessors
    
    fileprivate(set) lazy var credentialsIncorrectAlertController: UIAlertController = {
        let _credentialsIncorrectAlertController = UIAlertController(title: nil, message: self.localizedString(key: "invalid_credentials.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "ok.title"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _credentialsIncorrectAlertController.addAction(cancelAction)
        return _credentialsIncorrectAlertController
    }()

    fileprivate(set) lazy var loginFailedAlertController: UIAlertController = {
        let _loginFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "user_login_fail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "ok.title"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _loginFailedAlertController.addAction(cancelAction)
        return _loginFailedAlertController
    }()

    // MARK: - Implementation of SSAuthenticationResetDelegate protocols

    func resetSuccess() {

    }
    
    // MARK: - Events
    
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder()
        }
    }
    
    func loginButtonAction() {
        self.tapAction()
        guard (self.isEmailValid && self.isPasswordValid) else {
            if (!self.isEmailValid) {
                if (!self.emailFailureAlertController.isBeingPresented) {
                    self.emailTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.emailFailureAlertController, animated: true, completion: nil)
                }
            } else {
                if (!self.passwordValidFailAlertController.isBeingPresented) {
                    self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.passwordValidFailAlertController, animated: true, completion: nil)
                }
            }
            return
        }
        
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            self.loginButton?.isUserInteractionEnabled = false
            self.showLoadingView()
            
            let userDict = [EMAIL_KEY: email,
                            PASSWORD_KEY: password]
            SSAuthenticationManager.sharedInstance.login(userDictionary: userDict) { (user: SSUser?, statusCode: Int, error: Error?) in
                if (user != nil) {
                    self.delegate?.loginSuccess(user!)
                } else {
                    if (statusCode == INVALID_STATUS_CODE) {
                        self.present(self.credentialsIncorrectAlertController, animated: true, completion: nil)
                    } else {
                        self.present(self.loginFailedAlertController, animated: true, completion: nil)
                    }
                }
                self.hideLoadingView()
                self.loginButton?.isUserInteractionEnabled = true
            }
        }
    }
    
    func resetButtonAction() {
        let resetViewController = SSAuthenticationResetPasswordViewController()
        resetViewController.delegate = self
        resetViewController.forceUpdateStatusBarStyle(self.statusBarStyle)
        resetViewController.emailTextField.text = self.emailTextField.text
        resetViewController.isEmailValid = self.isEmailValid
        resetViewController.view.backgroundColor = self.view.backgroundColor
        self.navigationController?.pushViewController(resetViewController, animated: true)
    }
        
    // MARK: - Public Methods
    
    override open func forceUpdateStatusBarStyle(_ style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style)
    }
    
    override open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.passwordTextField) {
            self.loginButtonAction()
        } else {
            self.passwordTextField.becomeFirstResponder()
        }
        return super.textFieldShouldReturn(textField)
    }
    
    // MARK: - Subviews
    
    fileprivate func setupLoginButton() {
        self.loginButton = UIButton(type: .system)
        self.loginButton?.backgroundColor = SSAuthenticationManager.sharedInstance.buttonBackgroundColour
        self.loginButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.login"), attributes: SSAuthenticationManager.sharedInstance.buttonFontAttribute), for: UIControlState())
        self.loginButton?.addTarget(self, action: .loginButtonAction, for: .touchUpInside)
        self.loginButton?.layer.cornerRadius = GENERAL_ITEM_RADIUS
    }
    
    fileprivate func setupResetButton() {
        self.resetButton = UIButton(type: .system)
        self.resetButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.forget_password"), attributes: SSAuthenticationManager.sharedInstance.resetButtonAttribute), for: UIControlState())
        self.resetButton?.addTarget(self, action: .resetButtonAction, for: .touchUpInside)
    }

    override func setupSubviews() {
        super.setupSubviews()

        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField)
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField)
                
        self.setupLoginButton()
        self.loginButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.loginButton!)

        self.setupResetButton()
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.resetButton!)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: .tapAction)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override open func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["email": self.emailTextField,
                                        "password": self.passwordTextField,
                                        "login": self.loginButton!,
                                        "reset": self.resetButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": ((IS_IPHONE_4S) ? (GENERAL_ITEM_HEIGHT - 10.0) : GENERAL_ITEM_HEIGHT),
                           "BUTTON_HEIGHT": GENERAL_ITEM_HEIGHT]
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[email(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[password(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[login]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[reset]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[login(BUTTON_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[reset(BUTTON_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = self.topLayoutGuide.length
        let bottom = self.bottomLayoutGuide.length
        self.baseScrollView?.contentInset = UIEdgeInsetsMake(top, 0.0, bottom, 0.0)
    }

    // MARK: - View lifecycle
    
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordValidFailAlertController.message = self.localizedString(key: "invalid_credentials.message")
        self.title = self.localizedString(key: "user.login")
        self.emailTextField.returnKeyType = .next
        self.passwordTextField.returnKeyType = .go
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailTextField.becomeFirstResponder()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
}

private extension Selector {
    static let loginButtonAction = #selector(SSAuthenticationLoginViewController.loginButtonAction)
    static let resetButtonAction = #selector(SSAuthenticationLoginViewController.resetButtonAction)
    static let tapAction = #selector(SSAuthenticationLoginViewController.tapAction)
}
