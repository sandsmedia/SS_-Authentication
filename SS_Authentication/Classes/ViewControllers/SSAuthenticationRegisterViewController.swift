//
//  SSAuthenticationRegisterViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationRegisterDelegate: class {
    func registerSuccess(_ user: SSUser)
}

open class SSAuthenticationRegisterViewController: SSAuthenticationBaseViewController {
    open weak var delegate: SSAuthenticationRegisterDelegate?
    
    fileprivate var registerButton: UIButton?
    
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

    fileprivate(set) lazy var emailAlreadyExistAlertController: UIAlertController = {
        let _emailAlreadyExistAlertController = UIAlertController(title: nil, message: self.localizedString(key: "email_exist_error.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "ok.title"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _emailAlreadyExistAlertController.addAction(cancelAction)
        return _emailAlreadyExistAlertController
    }()

    fileprivate(set) lazy var registerFailedAlertController: UIAlertController = {
        let _registerFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "user_register_fail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "ok.title"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _registerFailedAlertController.addAction(cancelAction)
        return _registerFailedAlertController
    }()

    // MARK: - Events
    
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder()
        }
    }

    func registerButtonAction() {
        self.tapAction()
        guard (self.isEmailValid && self.isPasswordValid && self.isConfirmPasswordValid) else {
            if (!self.isEmailValid) {
                if (!self.emailFailureAlertController.isBeingPresented) {
                    self.emailTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.emailFailureAlertController, animated: true, completion: nil)
                }
            } else if (!self.isPasswordValid) {
                if (!self.passwordValidFailAlertController.isBeingPresented) {
                    self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.passwordValidFailAlertController, animated: true, completion: nil)
                }
            } else {
                if (!self.confirmPasswordValidFailAlertController.isBeingPresented) {
                    self.confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.confirmPasswordValidFailAlertController, animated: true, completion: nil)
                }
            }
            return
        }
        
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            self.registerButton?.isUserInteractionEnabled = false
            self.showLoadingView()

            let userDict = [EMAIL_KEY: email,
                            PASSWORD_KEY: password]
            SSAuthenticationManager.sharedInstance.emailValidate(email: email) { (bool: Bool, statusCode: Int, error: Error?) in
                if (bool) {
                    SSAuthenticationManager.sharedInstance.register(userDictionary: userDict) { (user: SSUser?, statusCode: Int, error: Error?) in
                        if (user != nil) {
                            self.delegate?.registerSuccess(user!)
                        } else {
                            if (statusCode == INVALID_STATUS_CODE) {
                                self.present(self.emailAlreadyExistAlertController, animated: true, completion: nil)
                            } else {
                                self.present(self.registerFailedAlertController, animated: true, completion: nil)
                            }
                        }
                        self.hideLoadingView()
                        self.registerButton?.isUserInteractionEnabled = true
                    }
                } else {
                    if (error != nil) {
                        self.present(self.registerFailedAlertController, animated: true, completion: nil)
                    } else {
                        self.present(self.emailFailureAlertController, animated: true, completion: nil)
                    }
                    self.hideLoadingView()
                    self.registerButton?.isUserInteractionEnabled = true
                }
            }
        }
    }
        
    // MARK: - Public Methods
    
    override open func forceUpdateStatusBarStyle(_ style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style)
    }
    
    override open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.confirmPasswordTextField) {
            self.registerButtonAction()
        } else if (textField == self.passwordTextField) {
            self.confirmPasswordTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.becomeFirstResponder()
        }
        return super.textFieldShouldReturn(textField)
    }

    // MARK: - Subviews
    
    fileprivate func setupRegisterButton() {
        self.registerButton = UIButton(type: .system)
        self.registerButton?.backgroundColor = SSAuthenticationManager.sharedInstance.buttonBackgroundColour
        self.registerButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.register"), attributes: SSAuthenticationManager.sharedInstance.buttonFontAttribute), for: UIControlState())
        self.registerButton?.addTarget(self, action: .registerButtonAction, for: .touchUpInside)
        self.registerButton?.layer.cornerRadius = GENERAL_ITEM_RADIUS
    }
    
    override func setupSubviews() {
        super.setupSubviews()
                
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField)
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField)
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField)
        
        self.setupRegisterButton()
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.registerButton!)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: .tapAction)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override open func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["email": self.emailTextField,
                                        "password": self.passwordTextField,
                                        "confirm": self.confirmPasswordTextField,
                                        "register": self.registerButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": ((IS_IPHONE_4S) ? (GENERAL_ITEM_HEIGHT - 10.0) : GENERAL_ITEM_HEIGHT),
                           "BUTTON_HEIGHT": GENERAL_ITEM_HEIGHT]
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[confirm]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[email(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[password(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[confirm(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[register]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[register(BUTTON_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
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
        
        self.title = self.localizedString(key: "user.register")
        self.emailTextField.returnKeyType = .next
        self.passwordTextField.returnKeyType = .next
        self.confirmPasswordTextField.returnKeyType = .go
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailTextField.becomeFirstResponder()
    }
}

private extension Selector {
    static let registerButtonAction = #selector(SSAuthenticationRegisterViewController.registerButtonAction)
    static let tapAction = #selector(SSAuthenticationRegisterViewController.tapAction)
}
