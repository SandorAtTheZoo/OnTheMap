//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/19/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation
import MapKit

class MapData: NSObject {
    
    static var allUserInformation : [StudentInformation] = [StudentInformation]()
    
    override init() {
        super.init()
        MapData.addStudentInformation(MapData.locData())
    }
    
    struct StudentInformation {
        var createdAt : String?
        var firstName : String?
        var lastName : String?
        var latitude : Double?
        var longitude : Double?
        var mapString : String?
        var mediaURL : String?
        var objectID : String?
        var uniqueKey : Int?
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
            self.uniqueKey = dict["uniqueKey"] as? Int
            self.updatedAt = dict["updatedAt"] as? String
        }
    }
    
        //create student variable
        //create functions as needed to update person from JSON
    static func addStudentInformation(studentArray:[[String:AnyObject]]) {
        var locArray = MapData.allUserInformation
        
        for item in studentArray {
            locArray.append(StudentInformation(dict: item))
        }
        MapData.allUserInformation = locArray
    }
    
    func placePins(studentLocations: [MapData.StudentInformation])->[MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for dictionary in studentLocations {
            //prepare location data
            //due to garbage in the Parse data, everything went to optionals, adding the if/let s
            if let latLoc = dictionary.latitude {
                let lat = CLLocationDegrees(dictionary.latitude!)
                if let longLoc = dictionary.longitude {
                    let long = CLLocationDegrees(dictionary.longitude!)
                    let coordinate = CLLocationCoordinate2DMake(lat, long)
                    
                    if let first = dictionary.firstName {
                        if let last = dictionary.lastName {
                            if let mediaURL = dictionary.mediaURL {
                                //create annotation and set coordinate, title, and subtitle properties
                                var annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                annotation.title = "\(first) \(last)"
                                annotation.subtitle = mediaURL
                                //put this annotation in array of annotations
                                annotations.append(annotation)
                            }
                        }
                    }
                }
            }
        }
        return annotations
    }
    
    static func newStudent() -> StudentInformation {
        var newStu = [
            "createdAt" : "",
            "firstName" : "",
            "lastName" : "",
            "latitude" : 0,
            "longitude" : 0,
            "mapString" : "",
            "mediaURL" : "",
            "objectId" : "",
            "uniqueKey" : 0,
            "updatedAt" : ""
        ]
        return MapData.StudentInformation(dict: newStu)
    }
    
    //apparently this method of singleton is a workaround for swift 1.1 inability to handle static class constants...
    //http://stackoverflow.com/questions/24024549/dispatch-once-singleton-model-in-swift
    class func sharedInstance() -> MapData {
        struct Singleton {
            static var sharedInstance = MapData()
        }
        return Singleton.sharedInstance
    }
    
    static func locData() -> [[String:AnyObject]] {
        return [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : 2256298598,
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : 2362758535,
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : 996618664,
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }
}