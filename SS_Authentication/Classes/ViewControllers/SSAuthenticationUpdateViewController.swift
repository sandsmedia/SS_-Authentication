//
//  SSAuthenticationUpdateViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationUpdateDelegate: class {
    func updateSuccess()
}

open class SSAuthenticationUpdateViewController: SSAuthenticationBaseViewController {
    open weak var delegate: SSAuthenticationUpdateDelegate?
    
    fileprivate var baseScrollView: UIScrollView?
    fileprivate var textFieldsStackView: UIStackView?
    fileprivate var buttonsStackView: UIStackView?
    fileprivate var updateButton: UIButton?
    
    open var isUpdateEmail = true

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

    fileprivate(set) lazy var emailUpdateSuccessAlertController: UIAlertController = {
        let _emailUpdateSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailUpdateSuccess.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            let _ = self.navigationController?.popViewController(animated: true)
        })
        _emailUpdateSuccessAlertController.addAction(cancelAction)
        return _emailUpdateSuccessAlertController
    }()
    
    fileprivate(set) lazy var emailUpdateFailedAlertController: UIAlertController = {
        let _emailUpdateFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailUpdateFail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _emailUpdateFailedAlertController.addAction(cancelAction)
        return _emailUpdateFailedAlertController
    }()

    fileprivate(set) lazy var passwordUpdateSuccessAlertController: UIAlertController = {
        let _passwordUpdateSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordUpdateSuccess.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            let _ = self.navigationController?.popViewController(animated: true)
        })
        _passwordUpdateSuccessAlertController.addAction(cancelAction)
        return _passwordUpdateSuccessAlertController
    }()
    
    fileprivate(set) lazy var passwordUpdateFailedAlertController: UIAlertController = {
        let _passwordUpdateFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordUpdateFail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _passwordUpdateFailedAlertController.addAction(cancelAction)
        return _passwordUpdateFailedAlertController
    }()

    // MARK: - Events
 
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder()
        }
    }

    func updateButtonAction() {
        self.tapAction()
        guard (self.isEmailValid || (self.isPasswordValid && self.isConfirmPasswordValid)) else {
            if (self.isUpdateEmail) {
                if (!self.emailFailureAlertController.isBeingPresented) {
                    self.emailTextField.layer.borderColor = UIColor.red.cgColor
                    self.present(self.emailFailureAlertController, animated: true, completion: nil)
                }
            } else {
                if (!self.isPasswordValid) {
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
            }
            return
        }
        
        self.updateButton?.isUserInteractionEnabled = false
        self.showLoadingView()
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        if (self.isUpdateEmail) {
            let userDict = [EMAIL_KEY: email]

            SSAuthenticationManager.sharedInstance.emailValidate(email: email) { (bool: Bool, statusCode: Int, error: Error?) in
                if (bool) {
                    SSAuthenticationManager.sharedInstance.updateEmail(userDictionary: userDict) { (user: SSUser?, statusCode: Int, error: Error?) in
                        if (user != nil) {
                            self.present(self.emailUpdateSuccessAlertController, animated: true, completion: nil)
                            self.delegate?.updateSuccess()
                        } else {
                            self.present(self.emailUpdateFailedAlertController, animated: true, completion: nil)
                        }
                        self.hideLoadingView()
                        self.updateButton?.isUserInteractionEnabled = true
                    }
                } else {
                    if (error != nil) {
                        self.present(self.emailUpdateFailedAlertController, animated: true, completion: nil)
                    } else {
                        self.present(self.emailFailureAlertController, animated: true, completion: nil)
                    }
                    self.hideLoadingView()
                    self.updateButton?.isUserInteractionEnabled = true
                }
            }
        } else {
            let userDict = [PASSWORD_KEY: password]
            
            SSAuthenticationManager.sharedInstance.updatePassword(userDictionary: userDict) { (user: SSUser?, statusCode: Int, error: Error?) in
                if (user != nil) {
                    self.present(self.passwordUpdateSuccessAlertController, animated: true, completion: nil)
                    self.delegate?.updateSuccess()
                } else {
                    self.present(self.passwordUpdateFailedAlertController, animated: true, completion: nil)
                }
                self.hideLoadingView()
                self.updateButton?.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Public Methods
    
    override open func forceUpdateStatusBarStyle(_ style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style)
    }
    
    override open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (self.isUpdateEmail) {
            self.updateButtonAction()
        } else {
            if (textField == self.confirmPasswordTextField) {
                self.updateButtonAction()
            } else {
                self.confirmPasswordTextField.becomeFirstResponder()
            }
        }
        return super.textFieldShouldReturn(textField)
    }

    // MARK: - Private Methods
    
    // MARK: - Subviews
    
    fileprivate func setupBaseScrollView() {
        self.baseScrollView = UIScrollView()
    }

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
    
    fileprivate func setupUpdateButton() {
        self.updateButton = UIButton(type: .system)
        self.updateButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.update"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.updateButton?.addTarget(self, action: .updateButtonAction, for: .touchUpInside)
        self.updateButton?.layer.borderWidth = 1.0
        self.updateButton?.layer.borderColor = UIColor.black.cgColor
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        self.setupBaseScrollView()
        self.baseScrollView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.baseScrollView!)

        self.setupTextFieldsStackView()
        self.textFieldsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseScrollView?.addSubview(self.textFieldsStackView!)
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField)
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: self.localizedString(key: "user.newPassword"), attributes: FONT_ATTR_MEDIUM_LIGHT_GRAY)
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField)
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField)
        
        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseScrollView?.addSubview(self.buttonsStackView!)
        
        self.setupUpdateButton()
        self.updateButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.updateButton!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: .tapAction)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override open func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["base": self.baseScrollView!,
                                        "texts": self.textFieldsStackView!,
                                        "email": self.emailTextField,
                                        "password": self.passwordTextField,
                                        "confirm": self.confirmPasswordTextField,
                                        "buttons": self.buttonsStackView!,
                                        "update": self.updateButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": ((IS_IPHONE_4S) ? (GENERAL_ITEM_HEIGHT - 10.0) : GENERAL_ITEM_HEIGHT),
                           "BUTTON_HEIGHT": GENERAL_ITEM_HEIGHT]

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[base]|", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[base]|", options: .directionMask, metrics: nil, views: views))

            self.baseScrollView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[texts]", options: .directionMask, metrics: nil, views: views))
            
            self.baseScrollView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[buttons]", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(SPACING)-[texts]-(LARGE_SPACING)-[buttons]|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseScrollView!.addConstraint(NSLayoutConstraint(item: self.textFieldsStackView!, attribute: .width, relatedBy: .equal, toItem: self.baseScrollView!, attribute: .width, multiplier: 1.0, constant: 0.0))
            
            self.baseScrollView!.addConstraint(NSLayoutConstraint(item: self.buttonsStackView!, attribute: .centerX, relatedBy: .equal, toItem: self.baseScrollView!, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.baseScrollView!.addConstraint(NSLayoutConstraint(item: self.textFieldsStackView!, attribute: .centerX, relatedBy: .equal, toItem: self.baseScrollView!, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.baseScrollView!.addConstraint(NSLayoutConstraint(item: self.buttonsStackView!, attribute: .width, relatedBy: .equal, toItem: self.baseScrollView!, attribute: .width, multiplier: 1.0, constant: 0.0))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[confirm]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[email(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[password(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[confirm(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[update]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[update(BUTTON_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = self.topLayoutGuide.length
        let bottom = self.bottomLayoutGuide.length
        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0)
        self.baseScrollView?.contentInset = newInsets
    }

    // MARK: - View lifecycle
    
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isUpdateEmail) {
            self.textFieldsStackView?.removeArrangedSubview(self.passwordTextField)
            self.passwordTextField.removeFromSuperview()
            self.textFieldsStackView?.removeArrangedSubview(self.confirmPasswordTextField)
            self.confirmPasswordTextField.removeFromSuperview()
            self.title = self.localizedString(key: "user.updateEmail")
            self.emailTextField.returnKeyType = .go
        } else {
            self.textFieldsStackView?.removeArrangedSubview(self.emailTextField)
            self.emailTextField.removeFromSuperview()
            self.title = self.localizedString(key: "user.updatePassword")
            self.passwordTextField.returnKeyType = .next
            self.confirmPasswordTextField.returnKeyType = .go
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.isUpdateEmail) {
            self.emailTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.becomeFirstResponder()
        }
    }
}

private extension Selector {
    static let tapAction = #selector(SSAuthenticationUpdateViewController.tapAction)
    static let updateButtonAction = #selector(SSAuthenticationUpdateViewController.updateButtonAction)
}
