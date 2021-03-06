//
//  AirportFetcher.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 12/1/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AirportFetcher: NSObject {
    
    let apiKey = "QabAhk6EsWj83KAUnbIeFdnzZyMzLxG6"
    let baseURL = "http://terminal2.expedia.com/x/suggestions/regions?query="
    var cityName: String
    var airportName: String
    
    init(cityName: String) {
        self.cityName = cityName
        self.airportName = "" // by default
        super.init()
    }
    
    private func makeRequestURL() -> NSURL {
        var requestURL = baseURL + cityName + "&apikey=" + apiKey
        requestURL = requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: requestURL)!
    }
    
    
    func downloadTask(completion: (result: String) -> Void) {

        let requestURL = self.makeRequestURL()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let downloadTask = session.dataTaskWithURL(requestURL, completionHandler: {(data, response, error) in
            if let responseData = data {

                let jsonResponse = JSON(data: responseData)
                self.airportName = jsonResponse["sr"][0]["a"].string!
                completion(result: self.airportName)
            }
            else {
                print("Error")
            }
            
            // Handle errors?
        })
        
        // Kick things off
        downloadTask.resume()

    }
}