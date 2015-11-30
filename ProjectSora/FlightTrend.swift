//
//  FlightTrend.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/30/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit

class FlightTrend {
    
    // MARK: Properties
    var date: NSDate
    var median: Double
    
    // MARK: Initializer
    init(date: NSDate, median: Double) {
        self.date = date
        self.median = median
    }
}