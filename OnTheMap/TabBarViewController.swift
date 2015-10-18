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
        //I have forgotten where I found this, but this stackoverflow basically describes it
        //make 2 buttons, put in array, assign array to rightBarButton
        //http://stackoverflow.com/questions/22812378/how-to-add-multiple-buttons-on-the-top-navigation-of-ios-app
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
                print("failed to logout")
                Alert(viewC: self, title: "Logout Error", errorString: "failed to logout")
            }
        }
        
    }
    
    
    //action for newPin button
    func addUserInfo() {
        //get storyboard and target view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        
        //make the transition
        self.presentViewController(resultVC, animated: true, completion: nil)
    }
    
    func refreshMap() {
        UserNWClient.sharedInstance().getStudentLocations({(success, errorString) in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName("updateMapNotify", object: nil)
            } else {
                Alert(viewC: self, title: "Refresh Failure", errorString: errorString!)
            }
        })
    }
}
