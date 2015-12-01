//
//  FlightTrendFetcher.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/30/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FlightTrendFetcher: NSObject {
    
    let apiKey = "QabAhk6EsWj83KAUnbIeFdnzZyMzLxG6"
    let baseURL = "http://terminal2.expedia.com/x/flights/v3/search/1/"
    var departureAirport: String
    var arrivalAirport: String
    var date: String
    var flightTrends: [FlightTrend]
    
    init(departureAirport: String, arrivalAirport: String, date: String) {
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.date = date
        self.flightTrends = [FlightTrend]()
    }
    
    func makeRequestURL() -> NSURL {
        var requestURL = baseURL + departureAirport + "/" + arrivalAirport + "/" + date + "/" + "?apikey=" + apiKey
        requestURL = requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: requestURL)!
    }
    
    func startDownloadTask(completion:([FlightTrend], Double)->Void) {
        let requestURL = self.makeRequestURL()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let downloadTask = session.dataTaskWithURL(requestURL, completionHandler: {(data, response, error) in
            if let responseData = data {
                let arrayOfFlightTrends = self.handleData(responseData)
                completion(arrayOfFlightTrends, self.getAverageMedian())
            }
            
            // Handle errors?
        })
        
        // Kick things off
        downloadTask.resume()
    }
    
    func handleData(data: NSData) -> [FlightTrend] {
        // Extract out the 21-day trend from recommended->trends->searchDate and recommended->trends->median
        let jsonResponse = JSON(data: data)
        let numberOfDays = jsonResponse["recommended"]["trends"].count
        var flightTrends = [FlightTrend]()
        
        for i in 0...numberOfDays-1 {
            let searchDate = jsonResponse["recommended"]["trends"][i]["searchDate"].string
            let medianString = jsonResponse["recommended"]["trends"][i]["median"].string
            let medianDouble = Double(medianString!)
            flightTrends.append(FlightTrend(date: searchDate!, median: medianDouble!))
        }
        self.flightTrends = flightTrends
        return flightTrends
    }
    
    // MARK: Helpers
    func getAverageMedian() -> Double {
        var runningTotal = 0.0
        for flightTrend in self.flightTrends {
            runningTotal += flightTrend.median
        }
        return runningTotal/Double(self.flightTrends.count)
    }
    
}