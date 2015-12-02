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
import PKHUD

class LaunchScreenViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, ChartViewDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties and Outlets
    
    let sharedLM = LocationManager.sharedLocationManager
    let citiesOfInterest = ["MSP", "SEA", "LAX", "JFK", "CHI"]
    let citiesOfInterestFull = ["Minneapolis", "Seattle", "Los Angeles", "New York City", "Chicago"]
    var avgFlightPriceForCities: [Double]
    
    @IBOutlet weak var radarChart : RadarChartView?
    @IBOutlet weak var departureAirport: UITextField!
    @IBOutlet weak var priceTableView: UITableView!

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.avgFlightPriceForCities = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.avgFlightPriceForCities = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.priceTableView.delegate = self
        self.title = "Destinations"
        self.departureAirport.placeholder = "Determining Location..."
        self.departureAirport.userInteractionEnabled = false
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Fetching flight trends to popular destinations...")
        PKHUD.sharedHUD.show()
        
        // Make navbar clear
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
        
        self.radarChart!.delegate = self
        self.radarChart!.descriptionText = ""
        self.radarChart!.noDataTextDescription = "You need to provide data for the chart."
        self.radarChart!.webLineWidth = 0.75
        self.radarChart!.innerWebLineWidth = 0.375
        self.radarChart!.webAlpha = 1.0
        self.radarChart?.highlightPerTapEnabled = true
        
        let xAxis = self.radarChart?.xAxis
        xAxis?.labelFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!

        let yAxis = self.radarChart?.yAxis
        yAxis?.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9.0)!
        yAxis?.labelCount = 5
        yAxis?.startAtZeroEnabled = true
        
        let legend = self.radarChart?.legend
        legend?.position = .RightOfChart
        legend?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)!
        legend?.xEntrySpace = 7.0
        legend?.yEntrySpace = 5.0
        self.radarChart?.hidden = true

        // Request for location permission
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.sharedLM.locationManager.requestWhenInUseAuthorization()
        }
        else {
            
            let count = self.citiesOfInterest.count
            var i = 0
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.sharedLM.startUpdatingLocation({
                let airportFetcher = AirportFetcher(cityName: self.sharedLM.currentCityName)
                airportFetcher.downloadTask({ (result) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.departureAirport.text = result
                    }
                    // We now have airport name
                    for cityOfInterest in self.citiesOfInterest {
                        
                        // For each city, we want to get the flight trend for that city
                        let flightTrendFetcher = FlightTrendFetcher(departureAirport: airportFetcher.airportName, arrivalAirport: cityOfInterest, date: "2015-12-21") // TODO : Use today date or something
                        
                        flightTrendFetcher.startDownloadTask({
                            (flightTrendForCity:[FlightTrend], avgForCity:Double)->Void in
                            self.avgFlightPriceForCities.append(avgForCity)
                            print("Fetching average for "+self.citiesOfInterest[i])
                            i++
                            if(i == count)
                            {
                                // finished
                                self.loadChartData()
                                self.sharedLM.stopUpdatingLocation()
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                dispatch_async(dispatch_get_main_queue(), {
                                    PKHUD.sharedHUD.hide()
                                    self.priceTableView.reloadData()
                                })
                            }
                        })
                        
                        // Sleep to prevent API call limit
                        NSThread.sleepForTimeInterval(0.25)
                    }
                    
                })
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        else if segue.identifier == "showActivitiesTableView" {
            let toVC = segue.destinationViewController as! ActivitiesTableViewController
            toVC.currentCity = City(name: "San Francisco", description: "Best city in the world") // Mock
        }
    }
    
    func showActivities() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("activities") as! ActivitiesTableViewController
        vc.currentCity = City(name: "Minneapolis", description: "Best city in the world")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadChartData() {
        
        // Use avgFlightPriceForCities for ["MSP", "SEA", "LAX", "JFK"]
        
        // No. of destinations
        let count = citiesOfInterest.count

        var yVals1 = [ChartDataEntry]()
        
        for i in 0...count-1 {
            yVals1.append(ChartDataEntry(value: self.avgFlightPriceForCities[i], xIndex: i))
        }
        
        var xVals = [NSString]()
        
        for i in 0...count-1 {
            // Destination/city name
            xVals.append(citiesOfInterest[i])
        }

        let set1 = RadarChartDataSet(yVals: yVals1, label: "Flight Trends for December 2015")
        set1.setColor(ChartColorTemplates.joyful().first!)
        set1.drawFilledEnabled = true
        set1.lineWidth = 2.0
        
        let data = RadarChartData(xVals: xVals, dataSets: [set1])
        
        data.setValueFont(UIFont.systemFontOfSize(16.0))//(name: "HelveticaNeue-Light", size: 12.0))
        data.setDrawValues(false)
        dispatch_async(dispatch_get_main_queue()) {
            self.radarChart?.hidden = false
            self.radarChart?.data = data
        }
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
    
    // MARK: CharViewDelegate
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        // select
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("activities") as! ActivitiesTableViewController
        vc.currentCity = City(name: "Minneapolis", description: "Best city in the world")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.citiesOfInterest.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cityPriceCell")
        
        dispatch_async(dispatch_get_main_queue(), {
            if (self.avgFlightPriceForCities.count > 0) {
                cell.textLabel?.text = String(format:"\(self.citiesOfInterestFull[indexPath.row]) $%.2f", self.avgFlightPriceForCities[indexPath.row])
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("activities") as! ActivitiesTableViewController
        vc.currentCity = City(name: "Minneapolis", description: "Best city in the world")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
