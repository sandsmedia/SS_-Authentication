//
//  SSAuthenticationManager.swift
//  SS_Authentication
//
//  Created by Eddie Li on 23/03/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

let TIME_OUT_INTERVAL = 120.0;
let TIME_OUT_RESOURCE = 600.0;

let INVALID_STATUS_CODE = 401;

let USER_KEY = "user";
let EMAIL_KEY = "email";
let TOKEN_KEY = "token";
let SS_AUTHENTICATION_TOKEN_KEY = "SS_AUTHENTICATION_TOKEN";

public class SSAuthenticationManager {
    public typealias ServiceResponse = (User?, NSError?) -> Void;
    
    // MARK: - Singleton Methods
    
    public static let sharedInstance: SSAuthenticationManager = {
        let instance = SSAuthenticationManager();
        return instance;
    }();
    
    // MARK: - Accessors
    
    private lazy var networkManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        configuration.HTTPShouldSetCookies = false;
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData;
        configuration.timeoutIntervalForRequest = TIME_OUT_INTERVAL;
        configuration.timeoutIntervalForResource = TIME_OUT_RESOURCE;
        let manager = Alamofire.Manager(configuration: configuration);
        return manager;
    }();
    
    private lazy var baseURL: String = {
        let _baseUrl = "http://video-cms-development.signsoft.com/";
        return _baseUrl;
    }();
    
    private lazy var registerURL: String = {
        let _registerURL = self.baseURL + "user";
        return _registerURL;
    }();
    
    private lazy var loginURL: String = {
        let _loginURL = self.baseURL + "user/login";
        return _loginURL;
    }();
    
    private lazy var validateURL: String = {
        let _validateURL = self.baseURL + "token/validate";
        return _validateURL;
    }();
    
    private lazy var resetURL: String = {
        let _resetURL = self.baseURL + "";
        return _resetURL;
    }();
    
    private lazy var updateURL: String = {
        let _updateURL = self.baseURL + "";
        return _updateURL;
    }();
    
    // MARK: - Public Methods
    
    public func register(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.registerURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("register: ", value);
                    let user = self.parse(responseJSON: value);
                    completionHandler(user, nil);
                case .Failure(let error):
                    print("register error: ", error);
                    completionHandler(nil, error);
                }
        }
        
    }
    
    public func login(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.loginURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("login: ", value);
                    let user = self.parse(responseJSON: value);
                    completionHandler(user, nil);
                case .Failure(let error):
                    print("login error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    public func validate(completionHandler completionHandler: ServiceResponse) -> Void {
        let token = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_TOKEN_KEY);
        guard (token != nil) else { completionHandler(nil, nil); return }
        self.networkManager.request(.POST, self.validateURL, parameters: [TOKEN_KEY: token!], encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("validate: ", value);
                    let user = self.parse(responseJSON: value);
                    completionHandler(user, nil);
                case .Failure(let error):
                    print("validate error: ", error);
                    if (response.response?.statusCode == INVALID_STATUS_CODE) {
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
                    }
                    completionHandler(nil, error);
                }
        }
    }
    
    public func logout(completionHandler completionHandler: ServiceResponse) -> Void {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        completionHandler(nil, nil);
    }
    
    public func reset(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.resetURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("reset: ", value);
                    let user = User();
                    user.email = (userDictionary[EMAIL_KEY] as! String);
                    completionHandler(user, nil);
                case .Failure(let error):
                    print("reset error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    public func update(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.updateURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    print("update: ", value);
                    let user = self.parse(responseJSON: value);
                    completionHandler(user, nil);
                case .Failure(let error):
                    print("update error: ", error);
                    completionHandler(nil, error);
                }
        }
    }
    
    private func parse(responseJSON responseJSON: AnyObject!) -> User {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let userDictionary = responseDictionary[USER_KEY]!.dictionaryValue;
        let email = userDictionary[EMAIL_KEY]?.stringValue;
        let token = userDictionary[TOKEN_KEY]?.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        let user = User();
        user.email = email;
        user.token = token;
        return user;
    }
}