//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class TabBarViewController :  UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updateMap : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshMap")
        
        let newPin : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "addUserInfo")
        
        let tabButtonArray : [UIBarButtonItem]? = [updateMap, newPin]
        
        self.navigationItem.rightBarButtonItems = tabButtonArray
    }
    
    
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        
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
    }
    
}
