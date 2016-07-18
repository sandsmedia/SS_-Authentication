//
//  SSAuthenticationLoginViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public protocol SSAuthenticationLoginDelegate: class {
    func loginSuccess(user: SSUser);
}

public class SSAuthenticationLoginViewController: SSAuthenticationBaseViewController, SSAuthenticationResetDelegate {
    public weak var delegate: SSAuthenticationLoginDelegate?;
    
    private var textFieldsStackView: UIStackView?;
    private var buttonsStackView: UIStackView?;
    private var loginButton: UIButton?;
    private var resetButton: UIButton?;
    
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
    
    private(set) lazy var credentialsIncorrectAlertController: UIAlertController = {
        let _credentialsIncorrectAlertController = UIAlertController(title: nil, message: self.localizedString(key: "invalidCredentials.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _credentialsIncorrectAlertController.addAction(cancelAction);
        return _credentialsIncorrectAlertController;
    }();

    private(set) lazy var loginFailedAlertController: UIAlertController = {
        let _loginFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "userLoginFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _loginFailedAlertController.addAction(cancelAction);
        return _loginFailedAlertController;
    }();

    // MARK: - Implementation of SSAuthenticationResetDelegate protocols

    func resetSuccess() {

    }
    
    // MARK: - Events
    
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder();
        }
    }
    
    func loginButtonAction() {
        self.tapAction();
        guard (self.isEmailValid && self.isPasswordValid) else {
            if (!self.isEmailValid) {
                if (!self.emailFailureAlertController.isBeingPresented()) {
                    self.emailTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
                }
            } else {
                if (!self.passwordValidFailAlertController.isBeingPresented()) {
                    self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor;
                    self.presentViewController(self.passwordValidFailAlertController, animated: true, completion: nil);
                }
            }
            return;
        }

        self.loginButton?.userInteractionEnabled = false;
        self.showLoadingView();
        let email = self.emailTextField.text as String!;
        let password = self.passwordTextField.text as String!;
        let userDict = [EMAIL_KEY: email,
                        PASSWORD_KEY: password];
        SSAuthenticationManager.sharedInstance.login(userDictionary: userDict) { (user, statusCode, error) in
            if (user != nil) {
                self.delegate?.loginSuccess(user!);
            } else {
                if (statusCode == INVALID_STATUS_CODE) {
                    self.presentViewController(self.credentialsIncorrectAlertController, animated: true, completion: nil);
                } else {
                    self.presentViewController(self.loginFailedAlertController, animated: true, completion: nil);
                }
            }
            self.hideLoadingView();
            self.loginButton?.userInteractionEnabled = true;
        };
    }
    
    func resetButtonAction() {
        let resetViewController = SSAuthenticationResetPasswordViewController();
        resetViewController.delegate = self;
        resetViewController.forceUpdateStatusBarStyle(self.statusBarStyle);
        resetViewController.updateNavigationBarColor(self.navigationBarColor);
        resetViewController.emailTextField.text = self.emailTextField.text;
        self.navigationController?.pushViewController(resetViewController, animated: true);
    }
        
    // MARK: - Public Methods
    
    override public func forceUpdateStatusBarStyle(style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style);
    }
    
    override public func updateNavigationBarColor(color: UIColor) {
        super.updateNavigationBarColor(color);
    }
    
    override public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.passwordTextField) {
            self.loginButtonAction();
        } else {
            self.passwordTextField.becomeFirstResponder();
        }
        return super.textFieldShouldReturn(textField);
    }
    
    // MARK: - Subviews
    
    private func setupTextFieldsStackView() {
        self.textFieldsStackView = UIStackView();
        self.textFieldsStackView?.axis = .Vertical;
        self.textFieldsStackView?.alignment = .Center;
        self.textFieldsStackView!.distribution = .EqualSpacing;
        self.textFieldsStackView?.spacing = GENERAL_SPACING;
    }
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView();
        self.buttonsStackView!.axis = .Vertical;
        self.buttonsStackView!.alignment = .Center;
        self.buttonsStackView!.distribution = .EqualSpacing;
        self.buttonsStackView?.spacing = 0.0;
    }
    
    private func setupLoginButton() {
        self.loginButton = UIButton(type: .System);
        self.loginButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.login"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal);
        self.loginButton?.addTarget(self, action: .loginButtonAction, forControlEvents: .TouchUpInside);
        self.loginButton?.layer.borderWidth = 1.0;
        self.loginButton?.layer.borderColor = UIColor.blackColor().CGColor;
    }
    
    private func setupResetButton() {
        self.resetButton = UIButton(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.forgetPassword"), attributes: FONT_ATTR_SMALL_BLACK), forState: .Normal);
        self.resetButton?.addTarget(self, action: .resetButtonAction, forControlEvents: .TouchUpInside);
    }

    override func setupSubviews() {
        super.setupSubviews();
        
        self.setupTextFieldsStackView();
        self.textFieldsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.textFieldsStackView!);
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField);
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField);
                
        self.setupButtonsStackView();
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.buttonsStackView!);
        
        self.setupLoginButton();
        self.loginButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.loginButton!);

        self.setupResetButton();
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.resetButton!);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: .tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override public func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "buttons": self.buttonsStackView!,
                         "login": self.loginButton!,
                         "reset": self.resetButton!];
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": ((IS_IPHONE_4S) ? (GENERAL_ITEM_HEIGHT - 10.0) : GENERAL_ITEM_HEIGHT),
                           "BUTTON_HEIGHT": GENERAL_ITEM_HEIGHT,
                           "XLARGE_SPACING": NAVIGATION_BAR_HEIGHT + GENERAL_SPACING];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(XLARGE_SPACING)-[texts]-(LARGE_SPACING)-[buttons]-(>=0)-|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[password]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views));

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[login]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[reset]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[login(BUTTON_HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views));
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[reset(BUTTON_HEIGHT)]", options: .DirectionMask, metrics: metrics, views: views));
            
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
        
        self.passwordValidFailAlertController.message = self.localizedString(key: "invalidCredentials.message");
        self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.login"), attributes: FONT_ATTR_LARGE_WHITE_BOLD);
        self.emailTextField.returnKeyType = .Next;
        self.passwordTextField.returnKeyType = .Go;
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.emailTextField.becomeFirstResponder();
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        
        self.emailTextField.text = nil;
        self.passwordTextField.text = nil;
    }
}

private extension Selector {
    static let loginButtonAction = #selector(SSAuthenticationLoginViewController.loginButtonAction);
    static let resetButtonAction = #selector(SSAuthenticationLoginViewController.resetButtonAction);
    static let tapAction = #selector(SSAuthenticationLoginViewController.tapAction);
}