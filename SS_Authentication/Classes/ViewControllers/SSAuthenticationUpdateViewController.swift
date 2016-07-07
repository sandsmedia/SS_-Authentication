//
//  SSAuthenticationUpdateViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationUpdateDelegate: class {
    func updateSuccess();
}

public class SSAuthenticationUpdateViewController: SSAuthenticationBaseViewController {
    public weak var delegate: SSAuthenticationUpdateDelegate?;
    
    private var textFieldsStackView: UIStackView?;
    private var buttonsStackView: UIStackView?;
    private var updateButton: UIButton?;
    
    public var isUpdateEmail = true;

    private var hasLoadedConstraints = false;

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
        self.delegate = nil;
    }
    
    // MARK: - Accessors
    
    private(set) lazy var emailAlreadyExistAlertController: UIAlertController = {
        let _emailAlreadyExistAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailExistError.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _emailAlreadyExistAlertController.addAction(cancelAction);
        return _emailAlreadyExistAlertController;
    }();

    private(set) lazy var emailUpdateSuccessAlertController: UIAlertController = {
        let _emailUpdateSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailUpdateSuccess.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.navigationController?.popViewControllerAnimated(true);
        });
        _emailUpdateSuccessAlertController.addAction(cancelAction);
        return _emailUpdateSuccessAlertController;
    }();
    
    private(set) lazy var emailUpdateFailedAlertController: UIAlertController = {
        let _emailUpdateFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "emailUpdateFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _emailUpdateFailedAlertController.addAction(cancelAction);
        return _emailUpdateFailedAlertController;
    }();

    private(set) lazy var passwordUpdateSuccessAlertController: UIAlertController = {
        let _passwordUpdateSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordUpdateSuccess.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.navigationController?.popViewControllerAnimated(true);
        });
        _passwordUpdateSuccessAlertController.addAction(cancelAction);
        return _passwordUpdateSuccessAlertController;
    }();
    
    private(set) lazy var passwordUpdateFailedAlertController: UIAlertController = {
        let _passwordUpdateFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "passwordUpdateFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _passwordUpdateFailedAlertController.addAction(cancelAction);
        return _passwordUpdateFailedAlertController;
    }();

    // MARK: - Events
 
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder();
        }
    }

    func updateButtonAction() {
        self.tapAction();
        guard (self.isEmailValid || (self.isPasswordValid && self.isConfirmPasswordValid)) else {
            if (self.isUpdateEmail) {
                if (!self.emailFailureAlertController.isBeingPresented()) {
                    self.emailTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
                }
            } else {
                if (!self.isPasswordValid) {
                    if (!self.passwordValidFailAlertController.isBeingPresented()) {
                        self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor;
                        self.presentViewController(self.passwordValidFailAlertController, animated: true, completion: nil);
                    }
                } else {
                    if (!self.confirmPasswordValidFailAlertController.isBeingPresented()) {
                        self.confirmPasswordTextField.layer.borderColor = UIColor.redColor().CGColor;
                        self.presentViewController(self.confirmPasswordValidFailAlertController, animated: true, completion: nil);
                    }
                }
            }
            return;
        }
        
        self.updateButton?.userInteractionEnabled = false;
        self.showLoadingView();
        let email = self.emailTextField.text ?? "";
        let password = self.passwordTextField.text ?? "";
        
        if (self.isUpdateEmail) {
            let userDict = [EMAIL_KEY: email];

            SSAuthenticationManager.sharedInstance.updateEmail(userDictionary: userDict) { (user, statusCode, error) in
                if (user != nil) {
                    self.presentViewController(self.emailUpdateSuccessAlertController, animated: true, completion: nil);
                    self.delegate?.updateSuccess();
                } else {
                    self.presentViewController(self.emailUpdateFailedAlertController, animated: true, completion: nil);
                }
                self.hideLoadingView();
                self.updateButton?.userInteractionEnabled = true;
            }
        } else {
            let userDict = [PASSWORD_KEY: password];
            
            SSAuthenticationManager.sharedInstance.updatePassword(userDictionary: userDict) { (user, statusCode, error) in
                if (user != nil) {
                    self.presentViewController(self.passwordUpdateSuccessAlertController, animated: true, completion: nil);
                    self.delegate?.updateSuccess();
                } else {
                    self.presentViewController(self.passwordUpdateFailedAlertController, animated: true, completion: nil);
                }
                self.hideLoadingView();
                self.updateButton?.userInteractionEnabled = true;
            }
        }
    }
    
    // MARK: - Public Methods
    
    override public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (self.isUpdateEmail) {
            self.updateButtonAction();
        } else {
            if (textField == self.confirmPasswordTextField) {
                self.updateButtonAction();
            } else {
                self.confirmPasswordTextField.becomeFirstResponder();
            }
        }
        return super.textFieldShouldReturn(textField);
    }

    // MARK: - Private Methods
    
    // MARK: - Subviews
    
    private func setupTextFieldsStackView() {
        self.textFieldsStackView = UIStackView();
        self.textFieldsStackView?.axis = .Vertical;
        self.textFieldsStackView?.alignment = .Center;
        self.textFieldsStackView!.distribution = .EqualSpacing;
        self.textFieldsStackView?.spacing = 20.0;
    }
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView();
        self.buttonsStackView!.axis = .Vertical;
        self.buttonsStackView!.alignment = .Center;
        self.buttonsStackView!.distribution = .EqualSpacing;
        self.buttonsStackView?.spacing = 20.0;
    }
    
    private func setupUpdateButton() {
        self.updateButton = UIButton(type: .System);
        self.updateButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.update"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal);
        self.updateButton?.addTarget(self, action: .updateButtonAction, forControlEvents: .TouchUpInside);
        self.updateButton?.layer.borderWidth = 1.0;
        self.updateButton?.layer.borderColor = UIColor.blackColor().CGColor;
    }
    
    override func setupSubviews() {
        super.setupSubviews();
        
        self.setupTextFieldsStackView();
        self.textFieldsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.textFieldsStackView!);
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField);
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: self.localizedString(key: "user.newPassword"), attributes: FONT_ATTR_MEDIUM_LIGHT_GRAY)
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField);
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField);
        
        self.setupButtonsStackView();
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.buttonsStackView!);
        
        self.setupUpdateButton();
        self.updateButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.updateButton!);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: .tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override public func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "confirm": self.confirmPasswordTextField,
                         "buttons": self.buttonsStackView!,
                         "update": self.updateButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[password]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[confirm]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[confirm(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[update]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[update(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }
    
    // MARK: - View lifecycle
    
    override public func loadView() {
        super.loadView();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isUpdateEmail) {
            self.textFieldsStackView?.removeArrangedSubview(self.passwordTextField);
            self.passwordTextField.removeFromSuperview();
            self.textFieldsStackView?.removeArrangedSubview(self.confirmPasswordTextField);
            self.confirmPasswordTextField.removeFromSuperview();
            self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.updateEmail"), attributes: FONT_ATTR_LARGE_BLACK_BOLD);
            self.emailTextField.returnKeyType = .Go;
        } else {
            self.textFieldsStackView?.removeArrangedSubview(self.emailTextField);
            self.emailTextField.removeFromSuperview();
            self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.updatePassword"), attributes: FONT_ATTR_LARGE_BLACK_BOLD);
            self.passwordTextField.returnKeyType = .Next;
            self.confirmPasswordTextField.returnKeyType = .Go;
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        if (self.isUpdateEmail) {
            self.emailTextField.becomeFirstResponder();
        } else {
            self.passwordTextField.becomeFirstResponder();
        }
    }
}

private extension Selector {
    static let tapAction = #selector(SSAuthenticationUpdateViewController.tapAction);
    static let updateButtonAction = #selector(SSAuthenticationUpdateViewController.updateButtonAction);
}