//
//  Activity.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 12/1/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation

class Activity {
    var title: String
    var imageURL: NSURL
    
    init(title: String, imageURL: NSURL) {
        self.title = title
        self.imageURL = imageURL
    }
}
