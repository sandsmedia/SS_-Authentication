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
    
    public var mailgunKey = "";
    public var user: SSUser?;
    public var profile: SSProfile?;
    public var email = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_EMAIL_KEY) as? String;
    public var password = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_PASSWORD_KEY) as? String;
    public var userId = NSUserDefaults.standardUserDefaults().objectForKey(SS_AUTHENTICATION_USER_ID_KEY) as? String;
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
        let _baseUrl = BASE_URL;
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

    private lazy var updateUserCourseURL: String = {
        let _updateUserCourseURL = self.baseURL + "user/%@/course/%@";
        return _updateUserCourseURL;
    }();

    private lazy var updateUserLessonURL: String = {
        let _updateUserLessonURL = self.baseURL + "user/%@/course/%@/lesson/%@";
        return _updateUserLessonURL;
    }();

    private lazy var updateUserChapterURL: String = {
        let _updateUserChapterURL = self.baseURL + "user/%@/course/%@/lesson/%@/chapter/%@";
        return _updateUserChapterURL;
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
                    self.email = userDictionary[EMAIL_KEY] as? String;
                    self.password = userDictionary[PASSWORD_KEY] as? String;
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY);
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY);
//                    SSAuthenticationManager.sharedInstance.getProfile(completionHandler: { (profile, statusCode, error) in
//                        print("getProfile update");
//                    });
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
                    self.email = userDictionary[EMAIL_KEY] as? String;
                    self.password = userDictionary[PASSWORD_KEY] as? String;
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY);
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY);
//                    SSAuthenticationManager.sharedInstance.getProfile(completionHandler: { (profile, statusCode, error) in
//                        print("getProfile update");
//                    });
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
//                    self.getProfile(completionHandler: { (profile, statusCode, error) in
//                        print("getProfile update");
//                    });
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
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_EMAIL_KEY);
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_PASSWORD_KEY);
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        self.email = nil;
        self.password = nil;
        self.accessToken = nil;
        self.user = nil;
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
        self.networkManager.request(.PUT, String(format: self.updateEmailURL, self.userId!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    self.email = userDictionary[EMAIL_KEY] as? String;
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updatePassword(userDictionary userDictionary: [String: AnyObject], completionHandler: UserResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.PUT, String(format: self.updatePasswordURL, self.userId!), parameters: userDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let user = self.parseSSUser(responseJSON: value);
                    self.password = userDictionary[PASSWORD_KEY] as? String;
                    NSUserDefaults.standardUserDefaults().setObject(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY);
                    completionHandler(user, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

//    public func updateProfile(profileDictionary profileDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
//        let headers = [X_TOKEN_KEY: self.accessToken!];
//        self.networkManager.request(.PUT, String(format: self.updateProfileURL, self.userId!), parameters: profileDictionary, encoding: .JSON, headers: headers)
//            .validate()
//            .responseJSON { response in
//                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
//                switch response.result {
//                case .Success(let value):
//                    print("updateProfile: ", value);
//                    let profile = self.parseSSProfile(responseJSON: value);
//                    completionHandler(profile, statusCode, nil);
//                case .Failure(let error):
//                    print("updateProfile error: ", error);
//                    completionHandler(nil, statusCode, error);
//                }
//        }
//    }

    public func updateUserCourse(userCourseDictionary userCourseDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        let courseId = userCourseDictionary[COURSE_ID_KEY] as! String;
        self.networkManager.request(.PUT, String(format: self.updateUserCourseURL, self.userId!, courseId), parameters: userCourseDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let profile = self.parseSSProfile(responseJSON: value);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updateUserLesson(userLessonDictionary userLessonDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        let courseId = userLessonDictionary[COURSE_ID_KEY] as! String;
        let lessonId = userLessonDictionary[LESSON_ID_KEY] as! String;
        self.networkManager.request(.PUT, String(format: self.updateUserLessonURL, self.userId!, courseId, lessonId), parameters: userLessonDictionary, encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let profile = self.parseSSProfile(responseJSON: value);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func updateUserChapter(userChapterDictionary userChapterDictionary: [String: AnyObject], completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        let courseId = userChapterDictionary[COURSE_ID_KEY] as! String;
        let lessonId = userChapterDictionary[LESSON_ID_KEY] as! String;
        let chapterId = userChapterDictionary[CHAPTER_ID_KEY] as! String;
        let favourite = userChapterDictionary[FAVOURITE_KEY] as! [String: AnyObject];
        self.networkManager.request(.PUT, String(format: self.updateUserChapterURL, self.userId!, courseId, lessonId, chapterId), parameters: [FAVOURITE_KEY: favourite], encoding: .JSON, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE;
                switch response.result {
                case .Success(let value):
                    let profile = self.parseSSProfile(responseJSON: value);
                    completionHandler(profile, statusCode, nil);
                case .Failure(let error):
                    completionHandler(nil, statusCode, error);
                }
        }
    }

    public func getProfile(completionHandler completionHandler: ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!];
        self.networkManager.request(.GET, String(format: self.getProfileURL, self.userId!), parameters: nil, encoding: .JSON, headers: headers)
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
        let user = SSUser();
        user.userId = userId;
        user.email = email;
        user.token = token;
        self.user = user;
        self.userId = userId;
        self.accessToken = token;
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: SS_AUTHENTICATION_USER_ID_KEY);
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: SS_AUTHENTICATION_TOKEN_KEY);
        return user;
    }
    
    private func parseSSProfile(responseJSON responseJSON: AnyObject!) -> SSProfile {
        let responseDictionary = JSON(responseJSON).dictionaryValue;
        let profileDictionary = responseDictionary[USER_KEY]!.dictionaryValue;
        let profileId = profileDictionary[ID_KEY]!.stringValue;
        let courses = profileDictionary[COURSES_KEY]!.arrayValue;
        let profile = SSProfile();
        profile.profileId = profileId;
        profile.courses = courses;
        self.profile = profile;
        return profile;
    }
}