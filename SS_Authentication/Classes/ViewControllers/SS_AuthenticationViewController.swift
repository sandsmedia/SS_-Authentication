//
//  SS_AuthenticationViewController.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import UIKit

public class SS_AuthenticationViewController: SS_AuthenticationBaseViewController {

    // MARK: - Initialisation
    
    convenience public init() {
        self.init(nibName: nil, bundle: nil);
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.setup();
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
    
    override public func loadView() {
        super.loadView();
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad();        
    }
}