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

public let SS_PROFILE_UPDATED_KEY = "SSProfileUpdated";

public class SSAuthenticationManager {
    public typealias EmailValidResponse = (Bool, Int, NSError?) -> Void;
    public typealias ServiceResponse = (Int, NSError?) -> Void;
    public typealias UserResponse = (SSUser?, Int, NSError?) -> Void;
    public typealias ProfileResponse = (SSProfile?, Int, NSError?) -> Void;
    
    public var mailgunKey: String = "";
    public var user: SSUser?;
    public var profile: SSProfile?;
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
    
    private lazy var updateFavouriteURL: String = {
        let _updateFavouriteURL = self.baseURL + "user/%@/favourite";
        return _updateFavouriteURL;
    }();
    
    private lazy var getProfileURL: String = {
        let _getProfileURL = self.baseURL + "user/%@";
        return _getProfileURL;
    }();

    private lazy var emailValidateURL: String = {
        let _emailValidateURL = "https://api.mailgun.net/v3/address/validate";
        return _emailValidateURL;
    }();
    
    // MARK: - Public Methods
    
    public func emailValidate(email email: String, completionHandler: EmailValidResponse) -> Void {
        let parameters = [ADDRESS_KEY: email,
                          API_KEY: self.mailgunKey];
        self.networkManager.request(.GET, self.emailValidateURL, parameters: parameters, encoding: .URLEncodedInURL, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let isValid = self.parseMailgun(responseJSON: value);
                    completionHandler(isValid, statusCode, nil);
                case .Failure(let error):
                    completionHandler(false, statusCode, error);
                }
        }
    }
    
    public func register(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        self.networkManager.request(.POST, self.registerURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    SSAuthenticationManager.sharedInstance.getProfile(completionHandler: { (profile, statusCode, error) in
                        print("getProfile update");
                    });
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
        
    }
    
    public func login(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        self.networkManager.request(.POST, self.loginURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    SSAuthenticationManager.sharedInstance.getProfile(completionHandler: { (profile, statusCode, error) in
                        print("getProfile update");
                    });
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func validate(completionHandler completionHandler: UserResponse) -> Void {
        let token = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_TOKEN_KEY);
        guard (token != nil) else { completionHandler(nil, ERROR_STATUS_CODE, nil); return }
        self.networkManager.request(.POST, self.validateURL, parameters: [TOKEN_KEY: token!], encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    SSAuthenticationManager.sharedInstance.getProfile(completionHandler: { (profile, statusCode, error) in
                        print("getProfile update");
                    });
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    if (statusCode == INVALID_STATUS_CODE) {
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
                        self.accessToken = nil;
                    }
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func logout(completionHandler completionHandler: UserResponse) -> Void {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        self.accessToken = nil;
        completionHandler(nil, ERROR_STATUS_CODE, nil);
    }
    
    public func reset(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        self.networkManager.request(.POST, self.resetURL, parameters: userDictionary, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = SSUser();
                    user.email = (userDictionary[EMAIL_KEY] as! String);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }
    
    public func updateEmail(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updateEmailURL, (self.user?.userId)!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updatePassword(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updatePasswordURL, (self.user?.userId)!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updateProfile(profileDictionary profileDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updateProfileURL, (self.user?.userId)!), parameters: profileDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("updateProfile: ", value);
                    let profile = self.parseSSProfile(responseJSON: value);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    print("updateProfile error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updateFavourite(favouriteDictionary favouriteDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updateFavouriteURL, (self.user?.userId)!), parameters: favouriteDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("updateFavourite: ", value);
                    let profile = self.parseSSProfile(responseJSON: value);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    print("updateFavourite error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func getProfile(completionHandler completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.GET, String(format: self.getProfileURL, (self.user?.userId)!), parameters: nil, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    print("getProfile: ", value);
                    let profile = self.parseSSProfile(responseJSON: value);
                    NSNotificationCenter.defaultCenter().postNotificationName(SS_PROFILE_UPDATED_KEY, object: profile);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    print("getProfile error: ", error);
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    // MARK: - Private Methods

    private func parseMailgun(responseJSON responseJSON: AnyObject!) -> Bool {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let isValid = responseDictionary[VALID_KEY]?.boolValue;
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
    
    private func parseSSProfile(responseJSON responseJSON: AnyObject!) -> SSProfile {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let profileDictionary = responseDictionary[PROFILE_KEY]!.dictionaryValue;
        let profileId = profileDictionary[ID_KEY]!.stringValue;
        let favourites = profileDictionary[FAVOURITE_KEY]!.arrayObject;
        let playlists = profileDictionary[PLAYLIST_KEY]!.arrayObject;
        let profile = SSProfile();
        profile.profileId = profileId;
        profile.favourites = favourites;
        profile.playlist = playlists;
        self.profile = profile;
        return profile;
    }
}