//
//  SSAuthenticationLoginViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationLoginDelegate: class {
    func loginSuccess(user: SSUser);
}

class SSAuthenticationLoginViewController: SSAuthenticationBaseViewController, SSAuthenticationResetDelegate {
    weak var delegate: SSAuthenticationLoginDelegate?;
    
    private var textFieldsStackView: UIStackView?;
    private var buttonsStackView: UIStackView?;
    private var loginButton: UIButton?;
    private var resetButton: UIButton?;
    
    private var hasLoadedConstraints: Bool = false;

    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        guard (self.isEmailValid && self.isPasswordValid) else { return }

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
        };
    }
    
    func resetButtonAction() {
        let resetViewController = SSAuthenticationResetPasswordViewController();
        resetViewController.delegate = self;
        resetViewController.emailTextField.text = self.emailTextField.text;
        self.navigationController?.pushViewController(resetViewController, animated: true);
    }
        
    // MARK: - Public Methods
    
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
    }
    
    private func setupLoginButton() {
        self.loginButton = UIButton(type: .System);
        self.loginButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.login"), attributes: FONT_ATTR_LARGE_WHITE_BOLD), forState: .Normal);
        self.loginButton?.addTarget(self, action: .loginButtonAction, forControlEvents: .TouchUpInside);
        self.loginButton?.layer.borderWidth = 1.0;
        self.loginButton?.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    private func setupResetButton() {
        self.resetButton = UIButton(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString(string: self.localizedString(key: "user.forgetPassword"), attributes: FONT_ATTR_SMALL_WHITE), forState: .Normal);
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
        
        self.passwordToggleButton.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.passwordToggleButton);
        
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
    
    override func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "toggle": self.passwordToggleButton,
                         "buttons": self.buttonsStackView!,
                         "login": self.loginButton!,
                         "reset": self.resetButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[password]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[toggle]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toggle]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[login]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[reset]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[login(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[reset(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }

    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordValidFailAlertController.message = self.localizedString(key: "invalidCredentials.message");
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.emailTextField.becomeFirstResponder();
    }
    
    override func viewDidDisappear(animated: Bool) {
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