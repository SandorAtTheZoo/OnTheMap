//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class TabBarViewController :  UITabBarController {
    
    var appDelegate : AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        //create 2 bar buttons on right hand side by creating array and passing array to right bar button item
        let updateMap : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshMap")
        let newPin : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "addUserInfo")
        let tabButtonArray : [UIBarButtonItem]? = [updateMap, newPin]
        self.navigationItem.rightBarButtonItems = tabButtonArray
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }
    
    
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        UserNWClient.sharedInstance().logout(appDelegate.au.baseURL) {(success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
                self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                println("failed to transition")
            }
        }
        
    }
    
    
    //action for newPin button
    func addUserInfo() {
        //get storyboard and target view controller
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var resultVC = storyboard.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        
        //make the transition
        self.presentViewController(resultVC, animated: true, completion: nil)
    }
    
    func refreshMap() {
        println("refresh")
        UserNWClient.sharedInstance().getStudentLocations({(success, errorString) in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName("updateMapNotify", object: nil)
            }
        })
    }
}
