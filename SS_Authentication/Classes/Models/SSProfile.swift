//
//  SSProfile.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SSProfile: NSObject {
    open var profileId: String = ""
    open var courses: [JSON] = []
}
