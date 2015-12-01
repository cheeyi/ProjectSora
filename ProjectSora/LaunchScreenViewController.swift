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
    
    let sharedLM = LocationManager.sharedLocationManager
    let citiesOfInterest = ["MSP", "SEA", "LAX", "JFK"]
    var flightTrendsForCities: [[FlightTrend]] // array of array of flight trends
    
    @IBOutlet weak var radarChart : RadarChartView?
    @IBOutlet weak var departureAirport: UITextField!

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.flightTrendsForCities = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
                
        self.radarChart!.delegate = self
        self.radarChart!.descriptionText = "Flight Trends"
        self.radarChart!.noDataTextDescription = "You need to provide data for the chart."
        self.radarChart!.webLineWidth = 0.75
        self.radarChart!.innerWebLineWidth = 0.375
        self.radarChart!.webAlpha = 1.0
        
//        self.radarChart?.marker = ChartMarker()
//        let marker = BalloonMarker(colo
//        BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
//        marker.minimumSize = CGSizeMake(80.f, 40.f);
//        _chartView.marker = marker;
        let xAxis = self.radarChart?.xAxis
        xAxis?.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9.0)!

        let yAxis = self.radarChart?.yAxis
        yAxis?.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9.0)!
        yAxis?.labelCount = 5
        yAxis?.startAtZeroEnabled = true
        
        let legend = self.radarChart?.legend
        legend?.position = .RightOfChart
        legend?.font = UIFont(name: "HelveticaNeue-Light", size: 10.0)!
        legend?.xEntrySpace = 7.0
        legend?.yEntrySpace = 5.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.radarChart?.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request for location permission
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.sharedLM.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.sharedLM.startUpdatingLocation({
                let airportFetcher = AirportFetcher(cityName: self.sharedLM.currentCityName)
                
                while (airportFetcher.airportName.isEmpty) {
                    // Hacky: Try till we get city name
                }
                self.departureAirport.text = airportFetcher.airportName
                
                // We now have airport name
                for cityOfInterest in self.citiesOfInterest {
                    
                    // For each city, we want to get the flight trend for that city, and append that to our flightTrendsForCities
                    let flightTrendFetcher = FlightTrendFetcher(departureAirport: airportFetcher.airportName, arrivalAirport: cityOfInterest, date: "2015-12-21")
                    
                    flightTrendFetcher.startDownloadTask({
                        (flightTrendForCity:[FlightTrend])->Void in
                        self.flightTrendsForCities.append(flightTrendForCity)
                    })
                    
                    // Sleep to prevent API call limit
                    NSThread.sleepForTimeInterval(0.25)
                }
                self.loadChartData()
                self.sharedLM.stopUpdatingLocation()
            })
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToCityDetails" {
            let toVC = segue.destinationViewController as! CityDetailsViewController
            toVC.currentCity = City(name: "Minneapolis", description: "Best city in the world") // Mock
        }
    }
    
    func loadChartData() {
        let flights = self.flightTrendsForCities
        let count = 9

        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        
        for i in 0...count-1 {
            yVals1.append(ChartDataEntry(value: 3, xIndex: i))
            yVals2.append(ChartDataEntry(value: 4, xIndex: i))
        }
        
        var xVals = [NSString]()
        
        for i in 0...count-1 {
            xVals.append("Team \(i)")
        }

        let set1 = RadarChartDataSet(yVals: yVals1, label: "Set 1")
        set1.setColor(ChartColorTemplates.vordiplom().first!)
        set1.drawFilledEnabled = true
        set1.lineWidth = 2.0
        
        let data = RadarChartData(xVals: xVals, dataSets: [set1])
        
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9.0))
        data.setDrawValues(false)
        self.radarChart?.hidden = false
        self.radarChart?.data = data
    }
    
    // MARK: Location Manager delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
