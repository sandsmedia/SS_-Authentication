//
//  SS_AuthenticationResetPasswordViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

class SS_AuthenticationResetPasswordViewController: SS_AuthenticationBaseViewController {
    
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
        
    }
    
    // MARK: - Public Methods
    
    // MARK: - Subviews
    
    override func setupSubviews() {
        super.setupSubviews();
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}