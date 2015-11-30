//
//  City.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/30/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit

class City {
    
    // MARK: Properties
    var name: String
    var description: String
    var headerPhoto: UIImage
    var detailsPhoto: UIImage?
    var rating: Int
    
    // MARK: Initializer
    init(name: String, description: String, headerPhoto: UIImage, rating: Int) {
        self.name = name
        self.description = description
        self.headerPhoto = headerPhoto
        self.rating = rating
    }
    
}