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
    // Singleton
    static let sharedLocationManager = LocationManager()
    
    var locationManager: CLLocationManager
    var currentLocation: CLLocation?
    
    override init() {
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 200
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: AnyObject? = (locations as NSArray).lastObject
        
        // Save location and print it out
        self.currentLocation = location as? CLLocation
        printLocation(self.currentLocation!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Update Location Error : \(error.description)")
    }
    
    func printLocation(currentLocation: CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, e) -> Void in
            if let _ = e {
                print("Error:  \(e!.localizedDescription)")
            }
            else {
                let placemark = placemarks!.last! as CLPlacemark
                
                let userInfo = [
                    "city":     placemark.locality,
                    "state":    placemark.administrativeArea,
                    "country":  placemark.country
                ]
                
                print("Location:  \(userInfo)")
                
                // Stop updating location once we pulled the location
                self.stopUpdatingLocation()
            }
        })
    }
}