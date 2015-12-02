//
//  CityDetailsViewController.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 12/1/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation

class CityDetailsViewController: UIViewController {
    let msp = City(name: "Minneapolis", description: "Best city in the world")
    let sea = City(name: "Seattle", description: "Second best city in the world")
    let lax = City(name: "Los Angeles", description: "Third best city in the world")
    let jfk = City(name: "New York City", description: "Fourth best city in the world")
    var currentCity: City
    
    @IBOutlet weak var cityDetailsTextView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCity = City(name: "TBD", description: "TBD")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "City"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = self.currentCity.name
        self.cityDetailsTextView.text = self.currentCity.description
    }
}