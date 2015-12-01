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

class LaunchScreenViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: Properties and Outlets
    let sharedLM = LocationManager()
    @IBOutlet weak var lineChart : LineChartView?
    @IBOutlet weak var departureAirport: UITextField!

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        lineChart = LineChartView(frame: CGRectZero)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        lineChart = LineChartView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Destinations"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request for location permission
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.sharedLM.locationManager.requestWhenInUseAuthorization()
        }
        else {
            let completion: ()->Void = {
                self.departureAirport.text = self.sharedLM.currentCityName
            }
            self.sharedLM.startUpdatingLocation(completion)
        }
        
        let a = FlightTrendFetcher(departureAirport: "MSP", arrivalAirport: "SFO", date: "2015-12-21")
        a.startDownloadTask()
        
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

