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
let IS_LARGER_DEVICE = (UIScreen.mainScreen().bounds.size.height > 568)

// MARK: - Font

let BASE_FONT_NAME = "HelveticaNeue"
let BASE_FONT_NAME_BOLD = "HelveticaNeue-Bold"

let FONT_SIZE_SMALL: CGFloat = ((IS_IPAD) ? 15.5 : 11.625)    // 27px @ 72dpi
let FONT_SIZE_MEDIUM: CGFloat = ((IS_IPAD) ? 20.0 : 15.275)   // 35px @ 72dpi
let FONT_SIZE_LARGE: CGFloat = ((IS_IPAD) ? 23.0 : 17.25)     // 40px @ 72dpi
let FONT_SIZE_XLARGE: CGFloat = ((IS_IPAD) ? 30.0 : 25.0)     // 40px @ 72dpi

let FONT_SMALL = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_SMALL)
let FONT_MEDIUM = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_MEDIUM)
let FONT_LARGE = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_LARGE)
let FONT_XLARGE = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_XLARGE)

let FONT_SMALL_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_SMALL)
let FONT_MEDIUM_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_MEDIUM)
let FONT_LARGE_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_LARGE)

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

// MARK: - Keys

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

// MARK: - General Config

let GENERAL_SPACING: CGFloat = 10.0
let SMALL_SPACING = GENERAL_SPACING / 2
let LARGE_SPACING = 2 * GENERAL_SPACING
let GENERAL_ITEM_WIDTH: CGFloat = 44.0
let GENERAL_ITEM_HEIGHT = GENERAL_ITEM_WIDTH
let SMALL_ITEM_WIDTH = GENERAL_ITEM_WIDTH / 2
let SMALL_ITEM_HEIGHT = SMALL_ITEM_WIDTH
let GENERAL_CELL_HEIGHT: CGFloat = 56.0
let NAVIGATION_BAR_HEIGHT: CGFloat = 64.0
let LOADING_DIAMETER: CGFloat = 10.0
let LOADING_RADIUS = LOADING_DIAMETER / 2

let ANIMATION_DURATION = 0.3

// MARK: - HTTP Reuqest

let BASE_URL = "http://video-cms-development.signsoft.com/"

let TIME_OUT_INTERVAL = 120.0;
let TIME_OUT_RESOURCE = 600.0;

let INVALID_STATUS_CODE = 401;
let NO_INTERNET_CONNECTION_STATUS_CODE = -1;
let ERROR_STATUS_CODE = 0;
