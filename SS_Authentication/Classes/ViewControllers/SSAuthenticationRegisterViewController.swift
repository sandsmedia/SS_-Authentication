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
    private var emailTextField: UITextField?;
    private var passwordTextField: UITextField?;
    private var confirmPasswordTextField: UITextField?;
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
        guard (self.emailTextField?.text?.characters.count > 0 && self.passwordTextField?.text?.characters.count > 0 && self.confirmPasswordTextField?.text?.characters.count > 0) else { return }
        guard (self.passwordTextField?.text == self.confirmPasswordTextField?.text) else { return }
        
        self.showLoadingView();
        let email = self.emailTextField?.text as String!;
        let password = self.passwordTextField?.text as String!;
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
    
    private func setupEmailTextField() {
        self.emailTextField = UITextField.init();
        self.emailTextField?.keyboardType = .EmailAddress;
        self.emailTextField?.attributedPlaceholder = NSAttributedString.init(string: "Email", attributes: nil);
        self.emailTextField?.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        self.emailTextField?.leftViewMode = .Always;
    }
    
    private func setupPasswordTextField() {
        self.passwordTextField = UITextField.init();
        self.passwordTextField?.secureTextEntry = true;
        self.passwordTextField?.attributedPlaceholder = NSAttributedString.init(string: "Password", attributes: nil);
        self.passwordTextField?.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        self.passwordTextField?.leftViewMode = .Always;
    }

    private func setupConfirmPasswordTextField() {
        self.confirmPasswordTextField = UITextField.init();
        self.confirmPasswordTextField?.secureTextEntry = true;
        self.confirmPasswordTextField?.attributedPlaceholder = NSAttributedString.init(string: "Confirm Password", attributes: nil);
        self.confirmPasswordTextField?.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        self.confirmPasswordTextField?.leftViewMode = .Always;
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
        
        self.setupEmailTextField();
        self.emailTextField?.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.emailTextField!);
        
        self.setupPasswordTextField();
        self.passwordTextField?.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.passwordTextField!);

        self.setupConfirmPasswordTextField();
        self.confirmPasswordTextField?.translatesAutoresizingMaskIntoConstraints = false;
        self.textFieldsStackView?.addArrangedSubview(self.confirmPasswordTextField!);

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
                         "email": self.emailTextField!,
                         "password": self.passwordTextField!,
                         "confirm": self.confirmPasswordTextField!,
                         "buttons": self.buttonsStackView!,
                         "register": self.registerButton!];
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[texts]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[buttons]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[texts]", options: .DirectionMask, metrics: nil, views: views));
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[buttons]-(20)-|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[email]|", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[password]|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[confirm]|", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[email(44)]", options: .DirectionMask, metrics: nil, views: views));
            
            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[password(44)]", options: .DirectionMask, metrics: nil, views: views));

            self.textFieldsStackView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[confirm(44)]", options: .DirectionMask, metrics: nil, views: views));

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
        super.viewDidLoad()
    }
}

private extension Selector {
    static let registerButtonAction = #selector(SSAuthenticationRegisterViewController.registerButtonAction);
    static let tapAction = #selector(SSAuthenticationRegisterViewController.tapAction);
}