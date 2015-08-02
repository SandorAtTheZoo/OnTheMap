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
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    var userLoc : CLLocation!
    var currStudent : StudentInformation = MapData.newStudent()
    var nwClient = UserNWClient()
    var appDelegate : AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        
        //try to run on GCD to get it to show
        //using Charles to throttle data to Apple at 56k to see transition
        dispatch_async(dispatch_get_main_queue(), {
            //geocoding start
            self.view.bringSubviewToFront(self.activityInd)
            self.activityInd.startAnimating()
        })
        if locationText.text != "" {
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
            //geocoding complete
            //stop animating not called until map zoom in GCD, as putting a call 
            //here seems to be too fast to display, but after the map zoom seems
            //to provide the best user experience
        }
        
    }
    
    @IBAction func submitUserInfo(sender: UIButton) {
        //create fake uniqueKey that happens to match what's in map data to invoke PUT or POST
        currStudent.uniqueKey = "4913"
        //check valid URL
        if let urlString = NSURL(string: userWebField.text) {
            userWebField.endEditing(true)
            currStudent.mediaURL = userWebField.text
        } else {
            //bad URL
            //errorInfo.text = "bad URL entered, try again"
            Alert(viewC: self, title: "Bad URL", errorString: "Not a valid URL")
        }
        
        //try to update existing student first
        updateUserInfo({locSuccess, locError in
            if locSuccess {
                println("udpating student info")
                //update student array with changes
                MapData.allUserInformation.append(self.currStudent)
                NSNotificationCenter.defaultCenter().postNotificationName("updateMapNotify", object: nil)
                //return to map screen
                self.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                
                //update student array with new student information
                MapData.allUserInformation.append(self.currStudent)
                
                //POST user info to the Parse server
                var httpData = MapData.dictionaryFromStudentForPost(self.currStudent)
                
                self.nwClient.postStudentLocation(httpData, completionHandler: {success, error in
                    if success {
                        println("successful POST")
                        NSNotificationCenter.defaultCenter().postNotificationName("updateMapNotify", object: nil)
                    } else {
                        Alert(viewC: self, title: "Student Info Error", errorString: error!)
                    }
                })
            }
        })
    }
    
    func updateUserInfo(completionHandler: (locSuccess: Bool, locError:String?)->Void) {
        //update user list
        nwClient.getStudentLocations({success, errorString in
            if success {
                //search new list for current user info
                if MapData.findStudent(self.currStudent.firstName!, lastName: self.currStudent.lastName!, uniqueKey: self.currStudent.uniqueKey!) {
                    //if match, update user rather than add new user
                    var httpData = MapData.dictionaryFromStudentForPost(self.currStudent)
                    self.nwClient.putStudentLocation(httpData, completionHandler: {success, error in
                        if success {
                            println("successful PUT")
                            completionHandler(locSuccess: true, locError: nil)
                        } else {
                            completionHandler(locSuccess: false, locError: nil)
                            Alert(viewC: self, title: "Creating new user", errorString: "cannot find existing user, creating new one")
                            println("failed PUT")
                        }
                    })
                }
            } else {
                completionHandler(locSuccess: false, locError: "data retrieval error")
                //issue error
                if let errStr = errorString {
                    Alert(viewC: self, title: "Data retrieval error", errorString: errStr)
                }
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
                    if let errStr = errorStr {
                        Alert(viewC: self, title: "Udacity Data retrieval", errorString: errStr)
                        //cancel post and return to map screen
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
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
        
        //geocoding complete, map zoomed in, now remove activity indicator
        self.activityInd.stopAnimating()
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
