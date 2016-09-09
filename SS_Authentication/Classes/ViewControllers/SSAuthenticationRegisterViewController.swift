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
    
    fileprivate var textFieldsStackView: UIStackView?
    fileprivate var buttonsStackView: UIStackView?
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
        let _emailAlreadyExistAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailExistError.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _emailAlreadyExistAlertController.addAction(cancelAction)
        return _emailAlreadyExistAlertController
    }()

    fileprivate(set) lazy var registerFailedAlertController: UIAlertController = {
        let _registerFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "userRegisterFail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
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

        self.registerButton?.isUserInteractionEnabled = false
        self.showLoadingView()
        let email = self.emailTextField.text as String!
        let password = self.passwordTextField.text as String!
        let userDict = [EMAIL_KEY: email,
                        PASSWORD_KEY: password]
        SSAuthenticationManager.sharedInstance.emailValidate(email: email!) { (bool: Bool, statusCode: Int, error: Error?) in
            if (bool) {
                SSAuthenticationManager.sharedInstance.register(userDictionary: userDict as [String : AnyObject]) { (user: SSUser?, statusCode: Int, error: Error?) in
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
        
    // MARK: - Public Methods
    
    override open func forceUpdateStatusBarStyle(_ style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style)
    }
    
    override open func updateNavigationBarColor(_ color: UIColor) {
        super.updateNavigationBarColor(color)
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
    
    fileprivate func setupTextFieldsStackView() {
        self.textFieldsStackView = UIStackView()
        self.textFieldsStackView?.axis = .vertical
        self.textFieldsStackView?.alignment = .center
        self.textFieldsStackView!.distribution = .equalSpacing
        self.textFieldsStackView?.spacing = GENERAL_SPACING
    }
    
    fileprivate func setupButtonsStackView() {
        self.buttonsStackView = UIStackView()
        self.buttonsStackView!.axis = .vertical
        self.buttonsStackView!.alignment = .center
        self.buttonsStackView!.distribution = .equalSpacing
        self.buttonsStackView?.spacing = GENERAL_SPACING
    }

    fileprivate func setupRegisterButton() {
        self.registerButton = UIButton(type: .system)
        self.registerButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.registerButton?.addTarget(self, action: .registerButtonAction, for: .touchUpInside)
        self.registerButton?.layer.borderWidth = 1.0
        self.registerButton?.layer.borderColor = UIColor.black.cgColor
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        self.setupTextFieldsStackView()
        self.textFieldsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.textFieldsStackView!)
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField)
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField)
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField)

        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.buttonsStackView!)
        
        self.setupRegisterButton()
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.registerButton!)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: .tapAction)
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationBar?.skipButton?.isHidden = true
    }
    
    override open func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "confirm": self.confirmPasswordTextField,
                         "buttons": self.buttonsStackView!,
                         "register": self.registerButton!] as [String : Any]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": ((IS_IPHONE_4S) ? (GENERAL_ITEM_HEIGHT - 10.0) : GENERAL_ITEM_HEIGHT),
                           "BUTTON_HEIGHT": GENERAL_ITEM_HEIGHT,
                           "XLARGE_SPACING": NAVIGATION_BAR_HEIGHT + GENERAL_SPACING]
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[texts]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[buttons]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(XLARGE_SPACING)-[texts]-(LARGE_SPACING)-[buttons]-(>=0)-|", options: .directionMask, metrics: metrics, views: views))
                        
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

    // MARK: - View lifecycle
    
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.register"), attributes: FONT_ATTR_LARGE_WHITE_BOLD)
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
