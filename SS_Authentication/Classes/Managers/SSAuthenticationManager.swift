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

public class SSAuthenticationManager {
    public typealias EmailValidResponse = (Bool, Int, NSError?) -> Void;
    public typealias ServiceResponse = (SSUser?, Int, NSError?) -> Void;
    
    public var mailgunKey: String = "";
    public var user: SSUser?;
    public var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_TOKEN_KEY) as? String;
    
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
        let _resetURL = self.baseURL + "user/reset";
        return _resetURL;
    }();
    
    private lazy var updateEmailURL: String = {
        let _updateEmailURL = self.baseURL + "user/%@/email";
        return _updateEmailURL;
    }();

    private lazy var updatePasswordURL: String = {
        let _updatePasswordURL = self.baseURL + "user/%@/password";
        return _updatePasswordURL;
    }();

    private lazy var updateProfileURL: String = {
        let _updateProfileURL = self.baseURL + "user/%@";
        return _updateProfileURL;
    }();

    private lazy var emailValidateURL: String = {
        let _emailValidateURL = "https://api.mailgun.net/v3/address/validate";
        return _emailValidateURL;
    }();
    
    // MARK: - Public Methods
    
    public func emailValidate(email email: String, completionHandler: EmailValidResponse) -> Void {
        let parameters = ["address": email,
                          "api_key": self.mailgunKey];
        self.networkManager.request(.GET, self.emailValidateURL, parameters: parameters, encoding: .URLEncodedInURL, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("emailValidate: ", value);
                    let isValid = self.parseMailgun(responseJSON: value);
                    completionHandler(isValid, statusCode, nil);
                case .Failure(let error):
                    print("emailValidate error: ", error);
                    completionHandler(false, statusCode, error);
                }
        }
    }
    
    public func register(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.registerURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("register: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("register error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
        
    }
    
    public func login(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.loginURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("login: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("login error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func validate(completionHandler completionHandler: ServiceResponse) -> Void {
        let token = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_TOKEN_KEY);
        guard (token != nil) else { completionHandler(nil, ERROR_STATUS_CODE, nil); return }
        self.networkManager.request(.POST, self.validateURL, parameters: [TOKEN_KEY: token!], encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("validate: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("validate error: ", error);
                    if (statusCode == INVALID_STATUS_CODE) {
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
                        self.accessToken = nil;
                    }
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func logout(completionHandler completionHandler: ServiceResponse) -> Void {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        self.accessToken = nil;
        completionHandler(nil, ERROR_STATUS_CODE, nil);
    }
    
    public func reset(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        self.networkManager.request(.POST, self.resetURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("reset: ", value);
                    let user = SSUser();
                    user.email = (userDictionary[EMAIL_KEY] as! String);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("reset error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func updateEmail(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        let headers = ["X-Token": self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updateEmailURL, (self.user?.userId)!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("update: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("update error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updatePassword(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        let headers = ["X-Token": self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updatePasswordURL, (self.user?.userId)!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("update: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("update error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updateProfile(userDictionary userDictionary: [String: AnyObject], completionHandler: ServiceResponse) -> Void {
        let headers = ["X-Token": self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updateProfileURL, (self.user?.userId)!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("update: ", value);
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    print("update error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    // MARK: - Private Methods

    private func parseMailgun(responseJSON responseJSON: AnyObject!) -> Bool {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let isValid = responseDictionary["is_valid"]?.boolValue;
        return isValid!;
    }

    private func parseSSUser(responseJSON responseJSON: AnyObject!) -> SSUser {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let userDictionary = responseDictionary[USER_KEY]!.dictionaryValue;
        let userId = userDictionary[ID_KEY]?.stringValue;
        let email = userDictionary[EMAIL_KEY]?.stringValue;
        let token = userDictionary[TOKEN_KEY]?.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        let user = SSUser();
        user.userId = userId;
        user.email = email;
        user.token = token;
        self.user = user;
        self.accessToken = token;
        return user;
    }
}