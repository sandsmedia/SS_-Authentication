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

open class SSAuthenticationManager {
    public typealias EmailValidResponse = (Bool, Int, Error?) -> Void
    public typealias ServiceResponse = (Int, Error?) -> Void
    public typealias UserResponse = (SSUser?, Int, Error?) -> Void
    public typealias ProfileResponse = (SSProfile?, Int, Error?) -> Void
    
    open var baseURL = ""
    open var mailgunKey = ""
    open var loadingViewColor = UIColor.gray
    open var user: SSUser?
    open var profile: SSProfile?
    open var email = UserDefaults.standard.object(forKey: SS_AUTHENTICATION_EMAIL_KEY) as? String
    open var password = UserDefaults.standard.object(forKey: SS_AUTHENTICATION_PASSWORD_KEY) as? String
    open var userId = UserDefaults.standard.object(forKey: SS_AUTHENTICATION_USER_ID_KEY) as? String
    open var accessToken = UserDefaults.standard.object(forKey: SS_AUTHENTICATION_TOKEN_KEY) as? String
    
    // MARK: - Singleton Methods
    
    open static let sharedInstance: SSAuthenticationManager = {
        let instance = SSAuthenticationManager()
        return instance
    }()
    
    // MARK: - Accessors
    
    fileprivate lazy var networkManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = TIME_OUT_INTERVAL
        configuration.timeoutIntervalForResource = TIME_OUT_RESOURCE
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    fileprivate lazy var registerURL: String = {
        let _registerURL = self.baseURL + "user"
        return _registerURL
    }()
    
    fileprivate lazy var loginURL: String = {
        let _loginURL = self.baseURL + "user/login"
        return _loginURL
    }()
    
    fileprivate lazy var validateURL: String = {
        let _validateURL = self.baseURL + "token/validate"
        return _validateURL
    }()
    
    fileprivate lazy var resetURL: String = {
        let _resetURL = self.baseURL + "user/reset"
        return _resetURL
    }()
    
    fileprivate lazy var updateEmailURL: String = {
        let _updateEmailURL = self.baseURL + "user/%@/email"
        return _updateEmailURL
    }()

    fileprivate lazy var updatePasswordURL: String = {
        let _updatePasswordURL = self.baseURL + "user/%@/password"
        return _updatePasswordURL
    }()
    
    fileprivate lazy var updateUserProfileURL: String = {
        let _updateUserProfileURL = self.baseURL + "user/%@/course"
        return _updateUserProfileURL
    }()

    fileprivate lazy var updateUserCourseURL: String = {
        let _updateUserCourseURL = self.baseURL + "user/%@/course/%@"
        return _updateUserCourseURL
    }()

    fileprivate lazy var updateUserLessonURL: String = {
        let _updateUserLessonURL = self.baseURL + "user/%@/course/%@/lesson/%@"
        return _updateUserLessonURL
    }()

    fileprivate lazy var updateUserChapterURL: String = {
        let _updateUserChapterURL = self.baseURL + "user/%@/course/%@/lesson/%@/chapter/%@"
        return _updateUserChapterURL
    }()
    
    fileprivate lazy var getUserProfileURL: String = {
        let _getUserProfileURL = self.baseURL + "user/%@"
        return _getUserProfileURL
    }()

    fileprivate lazy var emailValidateURL: String = {
        let _emailValidateURL = "https://api.mailgun.net/v3/address/validate"
        return _emailValidateURL
    }()
    
    // MARK: - Public Methods
    
    open func emailValidate(email: String, completionHandler: @escaping EmailValidResponse) -> Void {
        let parameters = [ADDRESS_KEY: email,
                          API_KEY: self.mailgunKey]
        self.networkManager.request(self.emailValidateURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let isValid = self.parseMailgun(responseJSON: value as AnyObject!)
                    completionHandler(isValid, statusCode, nil)
                case .failure(let error):
                    completionHandler(false, statusCode, error)
                }
        }
    }
    
    open func register(userDictionary: [String: AnyObject], completionHandler: @escaping UserResponse) -> Void {
        self.networkManager.request(self.registerURL, method: .post, parameters: userDictionary, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let user = self.parseSSUser(responseJSON: value as AnyObject!)
                    self.email = userDictionary[EMAIL_KEY] as? String
                    self.password = userDictionary[PASSWORD_KEY] as? String
                    UserDefaults.standard.set(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY)
                    UserDefaults.standard.set(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    completionHandler(nil, statusCode, error)
                }
        }
        
    }
    
    open func login(userDictionary: [String: AnyObject], completionHandler: @escaping UserResponse) -> Void {
        self.networkManager.request(self.loginURL, method: .post, parameters: userDictionary, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let user = self.parseSSUser(responseJSON: value as AnyObject!)
                    self.email = userDictionary[EMAIL_KEY] as? String
                    self.password = userDictionary[PASSWORD_KEY] as? String
                    UserDefaults.standard.set(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY)
                    UserDefaults.standard.set(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    completionHandler(nil, statusCode, error)
                }
        }
    }
    
    open func validate(completionHandler: @escaping UserResponse) -> Void {
        let token = UserDefaults.standard.object(forKey: SS_AUTHENTICATION_TOKEN_KEY)
        guard (token != nil) else { completionHandler(nil, ERROR_STATUS_CODE, nil); return }
        self.networkManager.request(self.validateURL, method: .post, parameters: [TOKEN_KEY: token!], encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let user = self.parseSSUser(responseJSON: value as AnyObject!)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    if (statusCode == INVALID_STATUS_CODE) {
                        UserDefaults.standard.set(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY)
                        self.accessToken = nil
                    }
                    completionHandler(nil, statusCode, error)
                }
        }
    }
    
    open func logout(completionHandler: UserResponse) -> Void {
        UserDefaults.standard.set(nil, forKey: SS_AUTHENTICATION_EMAIL_KEY)
        UserDefaults.standard.set(nil, forKey: SS_AUTHENTICATION_PASSWORD_KEY)
        UserDefaults.standard.set(nil, forKey: SS_AUTHENTICATION_TOKEN_KEY)
        self.email = nil
        self.password = nil
        self.accessToken = nil
        self.user = nil
        completionHandler(nil, ERROR_STATUS_CODE, nil)
    }
    
    open func reset(userDictionary: [String: AnyObject], completionHandler: @escaping UserResponse) -> Void {
        self.networkManager.request(self.resetURL, method: .post, parameters: userDictionary, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    print("value: ", value)
                    let user = SSUser()
                    user.email = (userDictionary[EMAIL_KEY] as! String)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    completionHandler(nil, statusCode, error)
                }
        }
    }
    
    open func updateEmail(userDictionary: [String: AnyObject], completionHandler: @escaping UserResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        self.networkManager.request(String(format: self.updateEmailURL, self.userId!), method: .put, parameters: userDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let user = self.parseSSUser(responseJSON: value as AnyObject!)
                    self.email = userDictionary[EMAIL_KEY] as? String
                    UserDefaults.standard.set(userDictionary[EMAIL_KEY], forKey: SS_AUTHENTICATION_EMAIL_KEY)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func updatePassword(userDictionary: [String: AnyObject], completionHandler: @escaping UserResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        self.networkManager.request(String(format: self.updatePasswordURL, self.userId!), method: .put, parameters: userDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let user = self.parseSSUser(responseJSON: value as AnyObject!)
                    self.password = userDictionary[PASSWORD_KEY] as? String
                    UserDefaults.standard.set(userDictionary[PASSWORD_KEY], forKey: SS_AUTHENTICATION_PASSWORD_KEY)
                    completionHandler(user, statusCode, nil)
                case .failure(let error):
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func updateUserProfile(userProfileDictionary: [String: AnyObject], completionHandler: @escaping ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        self.networkManager.request(String(format: self.updateUserProfileURL, self.userId!), method: .put, parameters: userProfileDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let profile = self.parseSSProfile(responseJSON: value as AnyObject!)
                    completionHandler(profile, statusCode, nil)
                case .failure(let error):
//                    print("resp: ", String(data: response.data!, encoding: UTF8StringEncoding))
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func updateUserCourse(userCourseDictionary: [String: AnyObject], completionHandler: @escaping ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        let courseId = userCourseDictionary[COURSE_ID_KEY] as! String
        self.networkManager.request(String(format: self.updateUserCourseURL, self.userId!, courseId), method: .put, parameters: userCourseDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let profile = self.parseSSProfile(responseJSON: value as AnyObject!)
                    completionHandler(profile, statusCode, nil)
                case .failure(let error):
//                    print("resp: ", String(data: response.data!, encoding: UTF8StringEncoding))
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func updateUserLesson(userLessonDictionary: [String: AnyObject], completionHandler: @escaping ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        let courseId = userLessonDictionary[COURSE_ID_KEY] as! String
        let lessonId = userLessonDictionary[LESSON_ID_KEY] as! String
        self.networkManager.request(String(format: self.updateUserLessonURL, self.userId!, courseId, lessonId), method: .put, parameters: userLessonDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let profile = self.parseSSProfile(responseJSON: value as AnyObject!)
                    completionHandler(profile, statusCode, nil)
                case .failure(let error):
//                    print("resp: ", String(data: response.data!, encoding: UTF8StringEncoding))
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func updateUserChapter(userChapterDictionary: [String: AnyObject], completionHandler: @escaping ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        let courseId = userChapterDictionary[COURSE_ID_KEY] as! String
        let lessonId = userChapterDictionary[LESSON_ID_KEY] as! String
        let chapterId = userChapterDictionary[CHAPTER_ID_KEY] as! String
        self.networkManager.request(String(format: self.updateUserChapterURL, self.userId!, courseId, lessonId, chapterId), method: .put, parameters: userChapterDictionary, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let profile = self.parseSSProfile(responseJSON: value as AnyObject!)
                    completionHandler(profile, statusCode, nil)
                case .failure(let error):
//                    print("resp: ", String(data: response.data!, encoding: UTF8StringEncoding))
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    open func getUserProfile(completionHandler: @escaping ProfileResponse) -> Void {
        let headers = [X_TOKEN_KEY: self.accessToken!]
        self.networkManager.request(String(format: self.getUserProfileURL, self.userId!), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? ERROR_STATUS_CODE
                switch response.result {
                case .success(let value):
                    let profile = self.parseSSProfile(responseJSON: value as AnyObject!)
                    completionHandler(profile, statusCode, nil)
                case .failure(let error):
//                    print("resp: ", String(data: response.data!, encoding: UTF8StringEncoding))
                    completionHandler(nil, statusCode, error)
                }
        }
    }

    // MARK: - Private Methods

    fileprivate func parseMailgun(responseJSON: AnyObject!) -> Bool {
        let responseDictionary = JSON(responseJSON).dictionaryValue
        let isValid = responseDictionary[VALID_KEY]?.boolValue
        return isValid!
    }

    fileprivate func parseSSUser(responseJSON: AnyObject!) -> SSUser {
        let responseDictionary = JSON(responseJSON).dictionaryValue
        let userDictionary = responseDictionary[USER_KEY]!.dictionaryValue
        let userId = userDictionary[ID_KEY]?.stringValue
        let email = userDictionary[EMAIL_KEY]?.stringValue
        let token = userDictionary[TOKEN_KEY]?.stringValue
        let user = SSUser()
        user.userId = userId
        user.email = email
        user.token = token
        self.user = user
        self.userId = userId
        self.accessToken = token
        UserDefaults.standard.set(token, forKey: SS_AUTHENTICATION_USER_ID_KEY)
        UserDefaults.standard.set(token, forKey: SS_AUTHENTICATION_TOKEN_KEY)
        return user
    }
    
    fileprivate func parseSSProfile(responseJSON: AnyObject!) -> SSProfile {
        let responseDictionary = JSON(responseJSON).dictionaryValue
        let profileDictionary = responseDictionary[USER_KEY]!.dictionaryValue
        let profileId = profileDictionary[ID_KEY]!.stringValue
        let courses = profileDictionary[COURSES_KEY]!.arrayValue
        let profile = SSProfile()
        profile.profileId = profileId
        profile.courses = courses
        self.profile = profile
        return profile
    }
}
