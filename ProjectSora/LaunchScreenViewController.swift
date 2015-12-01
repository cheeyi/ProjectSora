//
//  LaunchScreenViewController.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/20/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Charts

class LaunchScreenViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, ChartViewDelegate {

    // MARK: Properties and Outlets
    let sharedLM = LocationManager()
    let citiesOfInterest = ["MSP", "SEA", "LAX", "JFK"]
    var flightTrendsForCities: [[FlightTrend]] // array of array of flight trends
    
    @IBOutlet weak var lineChart : LineChartView?
    @IBOutlet weak var departureAirport: UITextField!

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        lineChart = LineChartView(frame: CGRectZero)
        self.flightTrendsForCities = []
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        lineChart = LineChartView(frame: CGRectZero)
        self.flightTrendsForCities = []
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Destinations"
        self.departureAirport.placeholder = "Determining..."
        
        // Make navbar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        self.lineChart!.translatesAutoresizingMaskIntoConstraints = false;
        
        self.lineChart!.delegate = self
        self.lineChart!.descriptionText = "Flight Trends"
        self.lineChart!.noDataTextDescription = "You need to provide data for the chart."
        self.lineChart!.dragEnabled = true
        self.lineChart!.setScaleEnabled(true)
        self.lineChart!.pinchZoomEnabled = true
        
        let leftAxis = self.lineChart!.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.customAxisMax = 6.0
        leftAxis.customAxisMin = 0.0
        leftAxis.startAtZeroEnabled = false
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        self.lineChart!.rightAxis.enabled = false
        self.lineChart!.legend.form = .Line
        
        self.lineChart!.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutQuart) // animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request for location permission
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.sharedLM.locationManager.requestWhenInUseAuthorization()
        }
        else {
            let completion: ()->Void = {
                // Completion block for when location is successfully determined
                let airportFetcher = AirportFetcher(cityName: self.sharedLM.currentCityName)
                
                
                airportFetcher.startDownloadTask()
                while (airportFetcher.airportName.isEmpty) {
                    // Hacky: Try till we get city name
                }
                self.departureAirport.text = airportFetcher.airportName
                
                // We now have airport name
                for cityOfInterest in self.citiesOfInterest {
                    // For each city, we want to get the flight trend for that city, and append that to our flightTrendsForCities
                    let flightTrendFetcher = FlightTrendFetcher(departureAirport: airportFetcher.airportName, arrivalAirport: cityOfInterest, date: "2015-12-21")
                    let innerCompletion = {(flightTrendForCity:[FlightTrend])->Void in
                        self.flightTrendsForCities.append(flightTrendForCity)
                    }
                    flightTrendFetcher.startDownloadTask(innerCompletion)
                    // Sleep to prevent API call limit
                    NSThread.sleepForTimeInterval(1.0)
                }
            }
            
            self.sharedLM.startUpdatingLocation(completion)
        }
        
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.sharedLM.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Location Manager delegate
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
}

