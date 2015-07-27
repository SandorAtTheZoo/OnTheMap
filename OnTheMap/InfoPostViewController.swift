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
    @IBOutlet weak var buttonViewPanel: UIView!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
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
        self.locationText.endEditing(true)
        if locationText.text != "" {
            errorInfo.text = "working..."
            var geoCode = CLGeocoder()
            geoCode.geocodeAddressString(locationText.text, completionHandler: {(placemarks, error) in
                if let geoError = error {
                    //add error code here
                    Alert(viewC: self, title: "Geocode error", errorString: "could not geocode location")
                } else {
                    for items in placemarks {
                        let name = items.name
                        let loc = items.addressDictionary
                        self.userLoc = items.location
                        self.currStudent.latitude = self.userLoc.coordinate.latitude
                        self.currStudent.longitude = self.userLoc.coordinate.longitude
                        self.currStudent.mapString = items.name
                        //println("placemark : \(items)\n name : \(name)\n location:\(loc)\n\n loc2: \(self.userLoc)")
                    }
                    self.updateLoc()
                }
            })
            errorInfo.text = "geocoding complete"
            
            var delayInSeconds = 1.0 * Double(NSEC_PER_SEC)
            var popTime : dispatch_time_t
            popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds))
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.errorInfo.text = ""
            })
        }
        
    }
    
    @IBAction func submitUserInfo(sender: UIButton) {
        //check valid URL
        if let urlString = NSURL(string: userWebField.text) {
            //success
            //errorInfo.text = ""
            userWebField.endEditing(true)
            currStudent.mediaURL = userWebField.text
            
            MapData.allUserInformation.append(currStudent)
            
            //return to map screen
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //bad URL
            //errorInfo.text = "bad URL entered, try again"
            Alert(viewC: self, title: "Bad URL", errorString: "Not a valid URL")
        }
        //POST user info to the Parse server
        var httpData = MapData.dictionaryFromStudentForPost(currStudent)

        nwClient.postStudentLocation(httpData, completionHandler: {success, error in
            if success {
                println("successful POST")
            } else {
                Alert(viewC: self, title: "Student Info Error", errorString: error!)
            }
        })
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
    
    //keyboard helper methods...can't push button when entering location text
    //know when keyboard rises and falls
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    //release notification when leaving the view
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    //called as selector from 'subscribeToKeyboardNotifications'
    //adjusts view frame to shift up display when keyboard shows
    func keyboardWillShow(notification: NSNotification) {
        if (locationText.isFirstResponder()) {
            self.findLocationOutlet.center.y -= getKeyboardHeight(notification)
        }
        if userWebField.isFirstResponder() {
            errorInfo.text = ""
        }
    }
    //called as selector from 'subscribeToKeyboardNotifications'
    //adjusts view frame to shift down display when keyboard hides
    func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y < 0 {
            self.findLocationOutlet.center.y += getKeyboardHeight(notification)
        }
    }
    //find out how tall keyboard is to know how much to shift display when it shows/hides
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //of CGRect
        return keyboardSize.CGRectValue().height
    }

}
