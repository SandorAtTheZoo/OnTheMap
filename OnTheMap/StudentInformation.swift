//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/28/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation

struct StudentInformation {
    var createdAt : String?
    var firstName : String?
    var lastName : String?
    var latitude : Double?
    var longitude : Double?
    var mapString : String?
    var mediaURL : String?
    var objectID : String?
    var uniqueKey : String?
    var updatedAt : String?
    
    //generate students from provided dictionary
    init(dict: [String:AnyObject]) {
        self.createdAt = dict["createdAt"] as? String
        self.firstName = dict["firstName"] as? String
        self.lastName = dict["lastName"] as? String
        self.latitude = dict["latitude"] as? Double
        self.longitude = dict["longitude"] as? Double
        self.mapString = dict["mapString"] as? String
        self.mediaURL = dict["mediaURL"] as? String
        self.objectID = dict["objectId"] as? String
        self.uniqueKey = dict["uniqueKey"] as? String
        self.updatedAt = dict["updatedAt"] as? String
    }
}