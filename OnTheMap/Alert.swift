//
//  Alert.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/26/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class Alert {
    init(viewC : UIViewController, title: String, errorString : String) {
        let alert = UIAlertController(title: title, message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)
        viewC.presentViewController(alert, animated: true, completion: nil)
    }
}
