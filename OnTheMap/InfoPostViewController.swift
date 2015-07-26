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
    
    var userLoc : CLLocation!

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
        findLocationOutlet.titleLabel?.text = "please wait, working..."
        if locationText.text != "" {
            var geoCode = CLGeocoder()
            geoCode.geocodeAddressString(locationText.text, completionHandler: {(placemarks, error) in
                for items in placemarks {
                    let name = items.name
                    let loc = items.addressDictionary
                    self.userLoc = items.location
                    println("placemark : \(items)\n name : \(name)\n location:\(loc)\n\n loc2: \(self.userLoc)")
                }
                //TODO: hide panels and stuff, show map, and add pin to map with location
                self.locationText.hidden = true
                self.locationPanel.hidden = true
                self.findButtonPanel.hidden = true
                self.mapViewPanel.hidden = false
                self.updateLoc()
            })
        }
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var myReuse = "here"
        var myPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myReuse)
        myPin.pinColor = .Red
        return myPin
    }
    
    func updateLoc() {
        var annotation = MKPointAnnotation()
        annotation.coordinate = userLoc.coordinate
        dispatch_async(dispatch_get_main_queue(), {
            self.mapViewPanel.addAnnotation(annotation)
        })
    }

}
