//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class TableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //update table on user refresh
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadUserData", name: "updateMapNotify", object: nil)
        reloadUserData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapData.allUserInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //reference cell
        let cell = tableView.dequeueReusableCellWithIdentifier("mapCell") as! UITableViewCell
        
        let user = MapData.allUserInformation[indexPath.row]
        
        //set cell to user data
        cell.textLabel?.text = user.firstName! + " " + user.lastName!
        cell.detailTextLabel?.text = user.mediaURL!
        
        return cell
    }
 
    //seems to fix problem where first table item ends up above viewable area...could see it if
    //you scrolled up
    override func viewDidLayoutSubviews() {
        let top = self.topLayoutGuide.length
        let bottom = self.bottomLayoutGuide.length
        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0)
        self.mapTableView.contentInset = newInsets
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //add call to browser here
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: MapData.allUserInformation[indexPath.row].mediaURL!)!)
    }
    
    func reloadUserData() {
        //updates table after refresh.  needed to use GCD to schedule it
        //otherwise table did not update, even when using reload data
        dispatch_async(dispatch_get_main_queue(), {
            //reload data when user refreshes the map
            self.mapTableView.reloadData()
        })

    }
}