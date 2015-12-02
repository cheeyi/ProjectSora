//
//  ActivitiesFetcher.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 12/1/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ActivitiesFetcher: NSObject {
    
    let apiKey = "QabAhk6EsWj83KAUnbIeFdnzZyMzLxG6"
    let baseURL = "http://terminal2.expedia.com/x/activities/search?location="
    var cityName: String
    
    init(cityName: String) {
        self.cityName = cityName
    }
    
    private func makeRequestURL() -> NSURL {
        var requestURL = baseURL + cityName + "&apikey=" + apiKey
        requestURL = requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: requestURL)!
    }
    
    func startDownloadTask(completion:[Activity]->Void) {
        let requestURL = self.makeRequestURL()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let downloadTask = session.dataTaskWithURL(requestURL, completionHandler: {(data, response, error) in
            if let responseData = data {
                let arrayOfActivities = self.handleData(responseData)
                completion(arrayOfActivities)
            }
            
            // Handle errors?
        })
        
        // Kick things off
        downloadTask.resume()
    }
    
    func handleData(data: NSData) -> [Activity] {
        // Extract activity titles, with a cap of 25
        let jsonResponse = JSON(data: data)
        var numberOfActivities = jsonResponse["activities"].count
        numberOfActivities = numberOfActivities > 25 ? 25 : numberOfActivities
        var activities = [Activity]()
        
        for i in 0...numberOfActivities-1 {
            let activityTitle = jsonResponse["activities"][i]["title"].string
            var activityURLString = (jsonResponse["activities"][i]["imageUrl"].string! as NSString).substringFromIndex(2)
            activityURLString = activityURLString.stringByReplacingOccurrencesOfString("hopscotch-star.us-east-1.prod.", withString: "")
            let activityURL = NSURL(string: "www."+activityURLString)
            activities.append(Activity(title: activityTitle!, imageURL: activityURL!))
        }
        return activities
    }
    
}