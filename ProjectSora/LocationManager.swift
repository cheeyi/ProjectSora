//
//  LocationManager.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/30/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    // Singleton location manager
    static let sharedLocationManager = LocationManager()
    
    var locationManager: CLLocationManager
    var currentLocation: CLLocation?
    var currentCityName: String
    
    override init() {
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 200
        self.currentCityName = ""
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager.startUpdatingLocation()
    }
    
    func startUpdatingLocation(completion:()->Void) {
        print("Starting Location Updates")
        self.locationManager.startUpdatingLocation()
        
        // Hacky: Wait 2 seconds before updating Departure Airport field
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if (!self.currentCityName.isEmpty) {
                completion()
            }
        })
        
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Grab last location
        let location: AnyObject? = (locations as NSArray).lastObject
        
        // Save location
        self.currentLocation = location as? CLLocation
        
        // Reverse geocode to get city, state and country strings
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.currentLocation!, completionHandler: { (placemarks, e) -> Void in
            if let _ = e {
                print("Error:  \(e!.localizedDescription)")
            }
            else {
                let placemark = placemarks!.last! as CLPlacemark
                
                self.currentCityName = placemark.locality!
                self.printLocation(self.currentLocation!)
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Update Location Error : \(error.description)")
    }
    
    func printLocation(currentLocation: CLLocation){
        print ("Current city: \(self.currentCityName)")
    }
}