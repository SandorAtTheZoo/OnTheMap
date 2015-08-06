//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/28/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation

//make student information hashable so it can be used as a dictionary in an array
//which means we can make a mutable set of StudentInformation, which means
//we can insert/replace items in a more optimal way than doing O(n^2) array
//sorts every time we get new information or want to insert/change student info
struct StudentInformation : Hashable {
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
    
    //didn't find in apple docs about conform to Hashable
    //http://samuelmullen.com/2014/10/implementing_swifts_hashable_protocol/
    //conform to Hashable :
    var hashValue: Int {
        if let hash = self.objectID!.toInt() {
            return hash
        } else {
            return 0
        }
        
    }
    
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

//not sure why I'm using this syntax except :
//https://www.andrewcbancroft.com/2015/07/01/every-swift-value-type-should-be-equatable/
//conform to protocol Equatable
//this function cannot be called within StudentInformation Type
func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    if lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.uniqueKey == rhs.uniqueKey {
            return true
    } else {
        return false
    }
}