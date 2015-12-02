//
//  ActivitiesTableViewController.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 12/1/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import UIKit

class ActivitiesTableViewController: UITableViewController {
    let msp = City(name: "Minneapolis", description: "Best city in the world")
    let sea = City(name: "Seattle", description: "Second best city in the world")
    let lax = City(name: "Los Angeles", description: "Third best city in the world")
    let jfk = City(name: "New York City", description: "Fourth best city in the world")
    var currentCity: City
    var activities: [Activity]
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCity = City(name: "TBD", description: "TBD") // set this properly in prepareForSegue:
        self.activities = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Network request 
        let activitiesFetcher = ActivitiesFetcher(cityName: self.currentCity.name)
        let completion = { (activityArray:[Activity])->Void in
            self.activities = activityArray
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        activitiesFetcher.startDownloadTask(completion)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Activities in " + self.currentCity.name
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)

        dispatch_async(dispatch_get_main_queue(), {
            cell.imageView!.sd_setImageWithURL(self.activities[indexPath.row].imageURL)
            cell.textLabel?.text = self.activities[indexPath.row].title
        })
        
        return cell
    }

}