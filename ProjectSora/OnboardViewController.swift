//
//  OnboardViewController.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/29/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import Foundation
import Onboard

class OnboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Hardcode this first to see onboarding every time
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kUserHasOnboardedKey")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let userHasOnboarded = NSUserDefaults.standardUserDefaults().boolForKey("kUserHasOnboardedKey")
        
        if !userHasOnboarded
        {
            // Handle onboarding
            
            // Set up onboarding content pages
            let firstPage = OnboardingContentViewController(title: "Welcome", body: "This app is going to rock your world", image: UIImage(named: "umbrella-icon"), buttonText: nil) { () -> Void in
                // Do something here when users press the button, like ask for location services permissions, register for push notifications
            }
            let secondPage = OnboardingContentViewController(title: "Getting to Know You", body: "We'll start by asking you some questions. Be honest!", image: UIImage(named: "umbrella-icon"), buttonText: nil) { () -> Void in
            }
            let thirdPage = OnboardingContentViewController(title: "Understanding You", body: "The app learns and understands what you like", image: UIImage(named: "umbrella-icon"), buttonText: nil) { () -> Void in
            }
            let fourthPage = OnboardingContentViewController(title: "Assisting You", body: "We then suggest full holiday packages based on your interests", image: UIImage(named: "umbrella-icon"), buttonText: "Let's get started!") { () -> Void in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kUserHasOnboardedKey")
                // Perform segue to survey questions
            }
            
            // Set up onboarding view controller
            let onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "haystack"), contents: [firstPage, secondPage, thirdPage, fourthPage])
            onboardingVC.allowSkipping = true
            onboardingVC.skipHandler = {() -> Void in
                // Copy completion block from last onboarding content VC's button completion above, and put it under the completion block below
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kUserHasOnboardedKey")
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
            // Present onboarding view controller modally
            self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.modalPresentationStyle = .CurrentContext
            self.presentViewController(onboardingVC, animated: true, completion: nil)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}