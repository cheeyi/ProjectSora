//
//  AppDelegate.swift
//  ProjectSora
//
//  Created by Chee Yi Ong on 11/20/15.
//  Copyright © 2015 Expedia MSP. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    enum ShortcutType: String
    {
        case TakeMeAway = "TakeMeAway"
        case Settings = "Settings"
        case RefineLearning = "RefineLearning"
    }
    
    // MARK: Application event handling
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Handle 3D Touch - Quick Actions
        var launchedFromShortCut = false

        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem
        {
            launchedFromShortCut = true
            handleShortCutItem(shortcutItem)
        }
        
        return !launchedFromShortCut
    }

    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    // MARK: 3D Touch handling
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: Bool -> Void)
    {
        // Called when app was in background and not suspended when Quick Action is the entry point
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        var handled = false
        
        if let shortcutType = ShortcutType.init(rawValue: shortcutItem.type) {
            // Pop to root view controller before performing segue
            let rootNavigationViewController = window!.rootViewController as? UINavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            rootNavigationViewController?.popToRootViewControllerAnimated(false)
            
            switch shortcutType
            {
            case .TakeMeAway:
                // Instantly see results/suggestions
                rootViewController?.performSegueWithIdentifier("segueToResults", sender: nil)
                handled = true
            case .Settings:
                // Zip to the Settings view
                rootViewController?.performSegueWithIdentifier("segueToSettings", sender: nil)
                handled = true
            case .RefineLearning:
                // Restart onboarding
                rootViewController?.performSegueWithIdentifier("segueToSurvey", sender: nil)
                handled = true
            }
        }
        return handled
    }
    
}

