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
    
    static var allUserInformation = Set<StudentInformation>()
    
    override init() {
        super.init()
        MapData.addStudentInformation(MapData.locData())
    }
    
        //create student variable
        //create functions as needed to update person from JSON
    static func addStudentInformation(studentArray:[[String:AnyObject]]) {
        
        for item in studentArray {
            MapData.allUserInformation.insert(StudentInformation(dict: item))
        }
    }
    
    static func dictionaryFromStudentForPost(aStudent:StudentInformation)-> String {
        var tempDict = NSMutableDictionary()
        tempDict["firstName"] = aStudent.firstName
        tempDict["lastName"] = aStudent.lastName
        tempDict["latitude"] = aStudent.latitude
        tempDict["longitude"] = aStudent.longitude
        tempDict["mapString"] = aStudent.mapString
        tempDict["mediaURL"] = aStudent.mediaURL
        tempDict["uniqueKey"] = aStudent.uniqueKey
        
        var convData = NSJSONSerialization.dataWithJSONObject(tempDict, options: nil, error: nil)
        var finalData : NSString = NSString(data: convData!, encoding: NSUTF8StringEncoding)!
        
        return finalData as! String
    }
    
    static func findStudent(firstName : String, lastName : String, uniqueKey : String)->Bool {
        for student in self.allUserInformation {
            let id = student.objectID
            if (student.firstName == firstName) && (student.lastName == lastName)  && (student.uniqueKey == uniqueKey){
                if let uniqueID = student.objectID {
                    let appDelegate :AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.au.parse_objectID = uniqueID
                    return true
                }
            }
        }
        return false
    }
    //based on apple docs for DateFormatters, NSComparator and
    //http://stackoverflow.com/questions/18195774/sorting-array-based-on-date-and-time-with-two-dictionary-keys
    //http://stackoverflow.com/questions/25769107/sort-nsarray-with-sortedarrayusingcomparator
    //although the apple docs actually had a better way to format than stackoverflow answer
    //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    //https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW7
    //http://stackoverflow.com/questions/805547/how-to-sort-an-nsmutablearray-with-custom-objects-in-it
    static func sortStudentsBasedOnTime(stuList: [StudentInformation])->[StudentInformation] {
        //first parse RFC 3339 date time (from apple)
        let dateFmtrfc3339 : NSDateFormatter = NSDateFormatter()
        let enPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFmtrfc3339.locale = enPosixLocale
        dateFmtrfc3339.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        dateFmtrfc3339.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        //now sort dates by StudentInformation
        var sortedArray : [StudentInformation]
        sortedArray = stuList.sorted({ (stu1, stu2) in
            var date1 : NSDate = dateFmtrfc3339.dateFromString(stu1.updatedAt!)!
            var date2 : NSDate = dateFmtrfc3339.dateFromString(stu2.updatedAt!)!
            if date1.compare(date2) == NSComparisonResult.OrderedDescending {
                return true
            } else {
                return false
            }
        })
        return sortedArray
    }
    
    func placePins(studentLocations: [StudentInformation])->[MKPointAnnotation] {
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
            "uniqueKey" : "",
            "updatedAt" : ""
        ]
        return StudentInformation(dict: newStu)
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