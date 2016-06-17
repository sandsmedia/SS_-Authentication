//
//  Constants.swift
//  SS_Authentication
//
//  Created by Eddie Li on 26/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import Foundation
import UIKit

let IOS_VERSION = (UIDevice.currentDevice().systemVersion as NSString).floatValue

let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
let IS_IPHONE_5 = (UIScreen.mainScreen().bounds.size.height == 568)
let IS_LARGER_DEVICE = (UIScreen.mainScreen().bounds.size.height > 568)
let IS_SMALLER_DEVICE = (UIScreen.mainScreen().bounds.size.height < 568)
let IS_RETINA = ((UIScreen.mainScreen().scale >= 2.0) ? true : false)
let IOS_8_OR_ABOVE = (IOS_VERSION >= 8.0)

// MARK: - Font

let BASE_FONT_NAME = "HelveticaNeue"
let BASE_FONT_NAME_BOLD = "HelveticaNeue-Bold"

let FONT_SIZE_SMALL = ((IS_IPAD) ? 15.5 : 11.625) as CGFloat   // 27px @ 72dpi
let FONT_SIZE_MEDIUM = ((IS_IPAD) ? 20.0 : 15.275) as CGFloat   // 35px @ 72dpi
let FONT_SIZE_LARGE = ((IS_IPAD) ? 23.0 : 17.25) as CGFloat     // 40px @ 72dpi
let FONT_SIZE_XLARGE = ((IS_IPAD) ? 30.0 : 25.0) as CGFloat     // 40px @ 72dpi
let FONT_SIZE_MENU = ((IS_IPAD) ? 15.275 : 15.275) as CGFloat    // 35px @ 72dpi

let FONT_SMALL = UIFont.init(name: BASE_FONT_NAME, size: FONT_SIZE_SMALL)
let FONT_MEDIUM = UIFont.init(name: BASE_FONT_NAME, size: FONT_SIZE_MEDIUM)
let FONT_LARGE = UIFont.init(name: BASE_FONT_NAME, size: FONT_SIZE_LARGE)
let FONT_XLARGE = UIFont.init(name: BASE_FONT_NAME, size: FONT_SIZE_XLARGE)
let FONT_MENU = UIFont.init(name: BASE_FONT_NAME, size: FONT_SIZE_MENU)

let FONT_SMALL_BOLD = UIFont.init(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_SMALL)
let FONT_MEDIUM_BOLD = UIFont.init(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_MEDIUM)
let FONT_LARGE_BOLD = UIFont.init(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_LARGE)

let FONT_COLOUR_BLACK = UIColor.blackColor()
let FONT_COLOUR_WHITE = UIColor.whiteColor()
let FONT_COLOUR_LIGHT_GRAY = UIColor.lightGrayColor()
let FONT_COLOUR_DARK_GRAY = UIColor.darkGrayColor()

let FONT_ATTR_SMALL_WHITE = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_SMALL_BLACK = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_SMALL_LIGHT_GRAY = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]
let FONT_ATTR_SMALL_DARK_GRAY = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]
let FONT_ATTR_SMALL_DARK_GRAY_BOLD = [NSFontAttributeName: FONT_SMALL_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]

let FONT_ATTR_MEDIUM_WHITE = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName:FONT_COLOUR_WHITE]
let FONT_ATTR_MEDIUM_BLACK = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_MEDIUM_LIGHT_GRAY = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]
let FONT_ATTR_MEDIUM_DARK_GRAY = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]
let FONT_ATTR_MEDIUM_WHITE_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_MEDIUM_BLACK_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_MEDIUM_LIGHT_GRAY_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]
let FONT_ATTR_MEDIUM_DARK_GRAY_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]

let FONT_ATTR_LARGE_WHITE = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_LARGE_BLACK = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_LARGE_LIGHT_GRAY = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]
let FONT_ATTR_LARGE_DARK_GRAY = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]
let FONT_ATTR_LARGE_WHITE_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_LARGE_BLACK_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_LARGE_LIGHT_GRAY_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]
let FONT_ATTR_LARGE_DARK_GRAY_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_DARK_GRAY]

let FONT_ATTR_XLARGE_BLACK = [NSFontAttributeName: FONT_XLARGE!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_XLARGE_WHITE = [NSFontAttributeName: FONT_XLARGE!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]

let FONT_ATTR_MENU_BLACK = [NSFontAttributeName: FONT_MENU!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_MENU_LIGHT_GRAY = [NSFontAttributeName: FONT_MENU!, NSForegroundColorAttributeName: FONT_COLOUR_LIGHT_GRAY]

let ADDRESS_KEY = "address";
let API_KEY = "api_key";
let X_TOKEN_KEY = "X-Token";
let VALID_KEY = "is_valid";
let USER_KEY = "user";
let ID_KEY = "id";
let EMAIL_KEY = "email";
let PASSWORD_KEY = "password";
let TOKEN_KEY = "token";
let PROFILE_KEY = "profile";
let FAVOURITE_KEY = "favourite";
let PLAYLIST_KEY = "playlist";
let SS_AUTHENTICATION_TOKEN_KEY = "SS_AUTHENTICATION_TOKEN";
let SS_FAVOURITES_KEY = "SS_FAVOURITES";

let PASSWORD_VALIDATION_REGEX = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,20}$";

let TIME_OUT_INTERVAL = 120.0;
let TIME_OUT_RESOURCE = 600.0;

let INVALID_STATUS_CODE = 401;
let NO_INTERNET_CONNECTION_STATUS_CODE = -1;
let ERROR_STATUS_CODE = 0;
