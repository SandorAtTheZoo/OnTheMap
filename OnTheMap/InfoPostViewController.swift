//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/19/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPostViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var findLocationOutlet: UIButton!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var locationPanel: UIView!
    @IBOutlet weak var findButtonPanel: UIView!
    @IBOutlet weak var mapViewPanel: MKMapView!
    @IBOutlet weak var whereStudyText: UILabel!
    @IBOutlet weak var userWebField: UITextField!
    @IBOutlet weak var errorInfo: UILabel!
    @IBOutlet weak var submitButt: UIButton!
    @IBOutlet var topView: UIView!
    
    var userLoc : CLLocation!
    var currStudent : MapData.StudentInformation = MapData.newStudent()
    var nwClient = UserNWClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func returnToDisplay(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func findLocation(sender: UIButton) {
        findLocationOutlet.enabled = false
        findLocationOutlet.titleLabel?.text = "working..."
        if locationText.text != "" {
            var geoCode = CLGeocoder()
            geoCode.geocodeAddressString(locationText.text, completionHandler: {(placemarks, error) in
                if let geoError = error {
                    //add error code here
                } else {
                    for items in placemarks {
                        let name = items.name
                        let loc = items.addressDictionary
                        self.userLoc = items.location
                        self.currStudent.latitude = self.userLoc.coordinate.latitude
                        self.currStudent.longitude = self.userLoc.coordinate.longitude
                        //println("placemark : \(items)\n name : \(name)\n location:\(loc)\n\n loc2: \(self.userLoc)")
                    }
                    self.updateLoc()
                }
            })
        }
        
    }
    
    @IBAction func submitUserInfo(sender: UIButton) {
        //check valid URL
        if let urlString = NSURL(string: userWebField.text) {
            //success
            errorInfo.text = ""
            currStudent.mediaURL = userWebField.text
            
            //TODO: POST to Parse server
            
            println("currStudent : \(currStudent)")
            MapData.allUserInformation.append(currStudent)
            
            //return to map screen
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //bad URL
            errorInfo.text = "bad URL entered, try again"
        }
        //TODO: POST user info to the Parse server
        println("POST to server")
        //TODO: on success, return to map view and refresh by notify
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var myReuse = "here"
        var myPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myReuse)
        myPin.pinColor = .Red
        return myPin
    }
    
    func updateLoc() {
        //hide panels and stuff, show map, and add pin to map with location
        self.locationText.hidden = true
        self.locationPanel.hidden = true
        self.findButtonPanel.hidden = true
        self.whereStudyText.hidden = true
        self.userWebField.hidden = false
        self.submitButt.hidden = false

        
        var annotation = MKPointAnnotation()
        annotation.coordinate = userLoc.coordinate
        dispatch_async(dispatch_get_main_queue(), {
            self.mapViewPanel.addAnnotation(annotation)
            self.zoomToLocation()
            self.nwClient.authGetInfo({userDict, success, errorStr in
                if success {
                    println("udacity GET success!!")
                    self.currStudent.firstName = userDict!["first_name"] as? String
                    self.currStudent.lastName = userDict!["last_name"] as? String
                } else {
                    //update UI string for failure
                    self.errorInfo.text = "did not retrieve user data from udacity"
                }
            })
            //fought with this for a bit to get button to display on top of map
            //ultimately may be that bringing button to front on main view worked
            self.topView.bringSubviewToFront(self.submitButt)
            self.mapViewPanel.hidden = false
        })
    }
    
    //referenced : http://stackoverflow.com/questions/13745115/animated-zoom-to-location-map-placemark-when-mapview-opened-ios
    func zoomToLocation() {
        var region = MKCoordinateRegion()
        region.center.latitude = self.currStudent.latitude!
        region.center.longitude = self.currStudent.longitude!
        region.span.latitudeDelta = CLLocationDegrees(0.15)
        region.span.longitudeDelta = CLLocationDegrees(0.15)
        mapViewPanel.setRegion(region, animated: true)
    }

}
