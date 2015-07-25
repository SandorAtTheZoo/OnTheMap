//
//  ViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMap", name: "updateMapNotify", object: nil)
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //TODO: make call to Parse from here, and update list of people for display
        self.updateMap()

    }
    
    func updateMap() {
        var annotations = [MKPointAnnotation]()
        annotations = MapData.sharedInstance().placePins(MapData.allUserInformation)
        println("RRRREFRESHED DATA:")

        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotations(annotations)
        })
        
    }

}

