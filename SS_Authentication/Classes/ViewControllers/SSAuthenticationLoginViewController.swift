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
    
    // MARK: - Implementation of SSAuthenticationResetDelegate protocols

    func resetSuccess() {

    }
    
    // MARK: - Events
    
    func loginButtonAction() {
        guard (self.isEmailValid && self.isPasswordValid) else { return }

        self.showLoadingView();
        let email = self.emailTextField.text as String!;
        let password = self.passwordTextField.text as String!;
        let userDict = [EMAIL_KEY: email,
                        PASSWORD_KEY: password];
        SSAuthenticationManager.sharedInstance.login(userDictionary: userDict) { (user, error) in
            if (user != nil) {
                self.delegate?.loginSuccess(user!);
            }
            self.hideLoadingView();
        };
    }
    
    func resetButtonAction() {
        let resetViewController = SSAuthenticationResetPasswordViewController.init();
        resetViewController.delegate = self;
        self.navigationController?.pushViewController(resetViewController, animated: true);
    }
    
    func tapAction() {
        for textField in (self.textFieldsStackView?.arrangedSubviews)! {
            textField.resignFirstResponder();
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Subviews
    
    private func setupTextFieldsStackView() {
        self.textFieldsStackView = UIStackView.init();
        self.textFieldsStackView?.axis = .Vertical;
        self.textFieldsStackView?.alignment = .Center;
        self.textFieldsStackView!.distribution = .EqualSpacing;
        self.textFieldsStackView?.spacing = 20.0;
    }
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView.init();
        self.buttonsStackView!.axis = .Vertical;
        self.buttonsStackView!.alignment = .Center;
        self.buttonsStackView!.distribution = .EqualSpacing;
        self.buttonsStackView?.spacing = 20.0;
    }
    
    private func setupLoginButton() {
        self.loginButton = UIButton.init(type: .System);
        self.loginButton?.setAttributedTitle(NSAttributedString.init(string: "Login", attributes: nil), forState: .Normal);
        self.loginButton?.addTarget(self, action: Selector.loginButtonAction, forControlEvents: .TouchUpInside);
    }
    
    private func setupResetButton() {
        self.resetButton = UIButton.init(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString.init(string: "Forgot Password", attributes: nil), forState: .Normal);
        self.resetButton?.addTarget(self, action: Selector.resetButtonAction, forControlEvents: .TouchUpInside);
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
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: Selector.tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "buttons": self.buttonsStackView!,
                         "login": self.loginButton!,
                         "reset": self.resetButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[password]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[login]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[reset]|", options: .DirectionMask, metrics: nil, views: views));
            
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
    }
}

private extension Selector {
    static let loginButtonAction = #selector(SSAuthenticationLoginViewController.loginButtonAction);
    static let resetButtonAction = #selector(SSAuthenticationLoginViewController.resetButtonAction);
    static let tapAction = #selector(SSAuthenticationLoginViewController.tapAction);
}