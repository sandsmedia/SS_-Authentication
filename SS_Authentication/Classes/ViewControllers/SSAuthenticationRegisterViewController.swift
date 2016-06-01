//
//  SSAuthenticationRegisterViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationRegisterDelegate: class {
    func registerSuccess(user: SSUser);
}

class SSAuthenticationRegisterViewController: SSAuthenticationBaseViewController {
    weak var delegate: SSAuthenticationRegisterDelegate?;
    
    private var textFieldsStackView: UIStackView?;
    private var buttonsStackView: UIStackView?;
    private var registerButton: UIButton?;
    
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
    
    // MARK: - Events
    
    func registerButtonAction() {
        guard (self.isEmailValid && self.isPasswordValid && self.isRetypePasswordValid) else { return }

        self.showLoadingView();
        let email = self.emailTextField.text as String!;
        let password = self.passwordTextField.text as String!;
        let userDict = [EMAIL_KEY: email,
                        PASSWORD_KEY: password];
        SSAuthenticationManager.sharedInstance.emailValidate(email: email) { (bool, error) in
            if (bool) {
                SSAuthenticationManager.sharedInstance.register(userDictionary: userDict) { (user, error) in
                    if (user != nil) {
                        self.delegate?.registerSuccess(user!);
                    }
                    self.hideLoadingView();
                }
            } else {
                self.hideLoadingView();
            }
        }
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

    private func setupRegisterButton() {
        self.registerButton = UIButton.init(type: .System);
        self.registerButton?.setAttributedTitle(NSAttributedString.init(string: "Register", attributes: nil), forState: .Normal);
        self.registerButton?.addTarget(self, action: Selector.registerButtonAction, forControlEvents: .TouchUpInside);
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

        self.retypePasswordTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.retypePasswordTextField);

        self.setupButtonsStackView();
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.buttonsStackView!);
        
        self.setupRegisterButton();
        self.registerButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.buttonsStackView?.addArrangedSubview(self.registerButton!);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: Selector.tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["texts": self.textFieldsStackView!,
                         "email": self.emailTextField,
                         "password": self.passwordTextField,
                         "retype": self.retypePasswordTextField,
                         "buttons": self.buttonsStackView!,
                         "register": self.registerButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[password]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[retype]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[retype(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[register]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.buttonsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[register(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.hasLoadedConstraints = true;
        }
        super.updateViewConstraints();
    }

    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
}

private extension Selector {
    static let registerButtonAction = #selector(SSAuthenticationRegisterViewController.registerButtonAction);
    static let tapAction = #selector(SSAuthenticationRegisterViewController.tapAction);
}