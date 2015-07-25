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
        //reload data when user refreshes the map
        mapTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapData.allUserInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //reference cell
        let cell = tableView.dequeueReusableCellWithIdentifier("mapCell") as! UITableViewCell
        
        let user = MapData.allUserInformation[indexPath.row]
        
        //set cell to user data
        cell.textLabel?.text = user.firstName! + user.lastName!
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
        //TODO: add call to browser here
    }
}