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
    
    private(set) lazy var forgotPasswordSuccessAlertController: UIAlertController = {
        let _forgotPasswordSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "forgotPasswordSuccess.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _forgotPasswordSuccessAlertController.addAction(cancelAction);
        return _forgotPasswordSuccessAlertController;
    }();

    private(set) lazy var forgotPasswordFailedAlertController: UIAlertController = {
        let _forgotPasswordFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "forgotPasswordFail.message"), preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .Cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder();
        });
        _forgotPasswordFailedAlertController.addAction(cancelAction);
        return _forgotPasswordFailedAlertController;
    }();

    // MARK: - Events
    
    func resetButtonAction() {
        guard (self.isEmailValid) else { return }

        self.showLoadingView();
        let email = self.emailTextField.text as String!;
        let userDict = [EMAIL_KEY: email];
        SSAuthenticationManager.sharedInstance.reset(userDictionary: userDict) { (user, statusCode, error) in
            if (user != nil) {
                self.presentViewController(self.forgotPasswordSuccessAlertController, animated: true, completion: nil);
                self.delegate?.resetSuccess();
            } else {
                self.presentViewController(self.forgotPasswordFailedAlertController, animated: true, completion: nil);
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
    
    private func setupResetButton() {
        self.resetButton = UIButton.init(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.restore"), attributes: FONT_ATTR_LARGE_WHITE_BOLD), forState: .Normal);
        self.resetButton?.addTarget(self, action: Selector.resetButtonAction, forControlEvents: .TouchUpInside);
        self.resetButton?.layer.borderWidth = 1.0;
        self.resetButton?.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    override func setupSubviews() {
        super.setupSubviews();
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.emailTextField);

        self.setupResetButton();
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.resetButton!);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: Selector.tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override func updateViewConstraints() {
        if (self.hasLoadedConstraints == false) {
            let views = ["email": self.emailTextField,
                         "reset": self.resetButton!];

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[email]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20)-[reset]-(20)-|", options: .DirectionMask, metrics: nil, views: views));

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