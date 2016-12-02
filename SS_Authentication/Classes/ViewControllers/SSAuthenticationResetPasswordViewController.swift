//
//  SSAuthenticationResetPasswordViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

protocol SSAuthenticationResetDelegate: class {
    func resetSuccess()
}

class SSAuthenticationResetPasswordViewController: SSAuthenticationBaseViewController {
    weak var delegate: SSAuthenticationResetDelegate?
    
    fileprivate var baseScrollView: UIScrollView?
    fileprivate var textFieldsStackView: UIStackView?
    fileprivate var buttonsStackView: UIStackView?
    fileprivate var resetButton: UIButton?

    fileprivate var hasLoadedConstraints = false

    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        self.delegate = nil
    }
    
    // MARK: - Accessors
    
    fileprivate(set) lazy var forgotPasswordSuccessAlertController: UIAlertController = {
        let _forgotPasswordSuccessAlertController = UIAlertController(title: nil, message: self.localizedString(key: "forgotPasswordSuccess.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            let _ = self.navigationController?.popViewController(animated: true)
        })
        _forgotPasswordSuccessAlertController.addAction(cancelAction)
        return _forgotPasswordSuccessAlertController
    }()

    fileprivate(set) lazy var forgotPasswordFailedAlertController: UIAlertController = {
        let _forgotPasswordFailedAlertController = UIAlertController(title: nil, message: self.localizedString(key: "forgotPasswordFail.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: self.localizedString(key: "cancelButtonTitle"), style: .cancel, handler: { (action) in
            self.emailTextField.becomeFirstResponder()
        })
        _forgotPasswordFailedAlertController.addAction(cancelAction)
        return _forgotPasswordFailedAlertController
    }()

    // MARK: - Events
    
    func resetButtonAction() {
        self.tapAction()
        guard (self.isEmailValid) else {
            if (!self.emailFailureAlertController.isBeingPresented) {
                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                self.present(self.emailFailureAlertController, animated: true, completion: nil)
            }
            return
        }

        if let email = self.emailTextField.text {
            self.resetButton?.isUserInteractionEnabled = false
            self.showLoadingView()
            
            let userDict = [EMAIL_KEY: email]
            SSAuthenticationManager.sharedInstance.reset(userDictionary: userDict) { (user: SSUser?, statusCode: Int, error: Error?) in
                if (user != nil) {
                    self.present(self.forgotPasswordSuccessAlertController, animated: true, completion: nil)
                    self.delegate?.resetSuccess()
                } else {
                    self.present(self.forgotPasswordFailedAlertController, animated: true, completion: nil)
                }
                self.hideLoadingView()
                self.resetButton?.isUserInteractionEnabled = true
            }
        }
    }
    
    func tapAction() {
        for textField in self.view.subviews {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Public Methods
    
    override internal func forceUpdateStatusBarStyle(_ style: UIStatusBarStyle) {
        super.forceUpdateStatusBarStyle(style)
    }
    
    override internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resetButtonAction()
        return super.textFieldShouldReturn(textField)
    }

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

    fileprivate func setupResetButton() {
        self.resetButton = UIButton(type: .system)
        self.resetButton?.setAttributedTitle(NSAttributedString.init(string: self.localizedString(key: "user.restore"), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: UIControlState())
        self.resetButton?.addTarget(self, action: .resetButtonAction, for: .touchUpInside)
        self.resetButton?.layer.borderWidth = 1.0
        self.resetButton?.layer.borderColor = UIColor.black.cgColor
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

        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseScrollView?.addSubview(self.buttonsStackView!)

        self.setupResetButton()
        self.resetButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.resetButton!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: .tapAction)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["base": self.baseScrollView!,
                                        "texts": self.textFieldsStackView!,
                                        "email": self.emailTextField,
                                        "buttons": self.buttonsStackView!,
                                        "reset": self.resetButton!]
            
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

            self.textFieldsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[email(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(LARGE_SPACING)-[reset]-(LARGE_SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[reset(BUTTON_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

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
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.localizedString(key: "user.restore")
        self.emailTextField.returnKeyType = .go
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailTextField.becomeFirstResponder()
    }
}

private extension Selector {
    static let resetButtonAction = #selector(SSAuthenticationResetPasswordViewController.resetButtonAction)
    static let tapAction = #selector(SSAuthenticationResetPasswordViewController.tapAction)
}
