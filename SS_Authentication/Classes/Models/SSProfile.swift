//
//  SSProfile.swift
//  SS_Authentication
//
//  Created by Eddie Li on 25/05/16.
//  Copyright © 2016 Software and Support Media GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SSProfile: NSObject {
    public var profileId: String = ""
    public var courses: [JSON] = []
}