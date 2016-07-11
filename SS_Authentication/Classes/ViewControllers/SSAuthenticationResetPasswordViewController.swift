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

    private var hasLoadedConstraints = false;

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
            self.navigationController?.popViewControllerAnimated(true);
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
        self.tapAction();
        guard (self.isEmailValid) else {
            if (!self.emailFailureAlertController.isBeingPresented()) {
                self.emailTextField.layer.borderColor = UIColor.redColor().CGColor;
                self.presentViewController(self.emailFailureAlertController, animated: true, completion: nil);
            }
            return;
        }

        self.resetButton?.userInteractionEnabled = false;
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
            self.resetButton?.userInteractionEnabled = true;
        };
    }
    
    func tapAction() {
        for textField in self.view.subviews {
            textField.resignFirstResponder();
        }
    }
    
    // MARK: - Public Methods
    
    override public func forceUpdateStatusBarStyle(style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style);
    }
    
    override public func updateNavigationBarColor(color: UIColor) {
        super.updateNavigationBarColor(color);
    }

    override public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.resetButtonAction();
        return super.textFieldShouldReturn(textField);
    }

    // MARK: - Subviews
    
    private func setupResetButton() {
        self.resetButton = UIButton(type: .System);
        self.resetButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.restore"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), forState: .Normal);
        self.resetButton?.addTarget(self, action: .resetButtonAction, forControlEvents: .TouchUpInside);
        self.resetButton?.layer.borderWidth = 1.0;
        self.resetButton?.layer.borderColor = UIColor.blackColor().CGColor;
    }
    
    override func setupSubviews() {
        super.setupSubviews();
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.emailTextField);

        self.setupResetButton();
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.resetButton!);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: .tapAction);
        self.view.addGestureRecognizer(tapGesture);
        
        self.navigationBar?.skipButton?.hidden = true;
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["email": self.emailTextField,
                         "reset": self.resetButton!];
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "XLARGE_SPACING": NAVIGATION_BAR_HEIGHT + GENERAL_SPACING];

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[email]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(LARGE_SPACING)-[reset]-(LARGE_SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));

            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(XLARGE_SPACING)-[email(HEIGHT)]-(>=1)-[reset(HEIGHT)]-(SPACING)-|", options: .DirectionMask, metrics: metrics, views: views));

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
        
        self.navigationBar?.titleLabel?.attributedText = NSAttributedString(string: self.localizedString(key: "user.restore"), attributes: FONT_ATTR_LARGE_WHITE_BOLD);
        self.emailTextField.returnKeyType = .Go;
    }
}

private extension Selector {
    static let resetButtonAction = #selector(SSAuthenticationResetPasswordViewController.resetButtonAction);
    static let tapAction = #selector(SSAuthenticationResetPasswordViewController.tapAction);
}