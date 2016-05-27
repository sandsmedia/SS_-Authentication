//
//  SSAuthenticationResetPasswordViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationResetDelegate: class {
    func resetSuccess();
}

class SSAuthenticationResetPasswordViewController: SSAuthenticationBaseViewController {
    weak var delegate: SSAuthenticationResetDelegate?;
    
    private var emailTextField: UITextField?;
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
    
    // MARK: - Events
    
    func resetButtonAction() {
        guard (self.emailTextField?.text?.characters.count > 0) else { return }

        self.showLoadingView();
        let email = self.emailTextField?.text as String!;
        let userDict = [EMAIL_KEY: email];
        SSAuthenticationManager.sharedInstance.reset(userDictionary: userDict) { (user, error) in
            if (user != nil) {
                self.delegate?.resetSuccess();
            }
            self.hideLoadingView();
        };
    }
    
    func tapAction() {
        for textField in self.view.subviews {
            textField.resignFirstResponder();
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Subviews
    
    private func setupEmailTextField() {
        self.emailTextField = UITextField.init();
        self.emailTextField?.keyboardType = .EmailAddress;
        self.emailTextField?.attributedPlaceholder = NSAttributedString.init(string: "Email", attributes: nil);
        self.emailTextField?.leftView = UIView.init(frame: CGRectMake(0, 0, 10, 0));
        self.emailTextField?.leftViewMode = .Always;
    }
    
    private func setupResetButton() {
        self.resetButton = UIButton.init(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString.init(string: "Reset", attributes: nil), forState: .Normal);
        self.resetButton?.addTarget(self, action: Selector.resetButtonAction, forControlEvents: .TouchUpInside);
    }
    
    override func setupSubviews() {
        super.setupSubviews();
        
        self.setupEmailTextField();
        self.emailTextField?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.emailTextField!);

        self.setupResetButton();
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.resetButton!);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: Selector.tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["email": self.emailTextField!,
                         "reset": self.resetButton!];

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[email]|", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[reset]|", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(84)-[email(44)]-(>=1)-[reset(44)]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

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
    static let resetButtonAction = #selector(SSAuthenticationResetPasswordViewController.resetButtonAction);
    static let tapAction = #selector(SSAuthenticationResetPasswordViewController.tapAction);
}