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
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCity = City(name: "TBD", description: "TBD")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Network request 
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Activities in " + self.currentCity.name
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // TODO: Change to actual number
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        cell.textLabel?.text = "Row #\(indexPath.row)"
        cell.detailTextLabel!.text = "Subtitle #\(indexPath.row)"
        
        return cell
    }
}