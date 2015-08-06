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
    
        //create student variable
        //create functions as needed to update person from JSON
    static func addStudentInformation(studentArray:[[String:AnyObject]]) {
        var locArray = MapData.allUserInformation
        
        for item in studentArray {
            locArray.append(StudentInformation(dict: item))
        }
        MapData.allUserInformation = updateAllStudents(MapData.allUserInformation, newStu: locArray) { (stu1, stu2) -> Int in
            var status = self.compareStudents(stu1 , stu2: stu2)
            println("status : \(status)")
            return status
        }
        //MapData.allUserInformation = locArray
    }
    
    static func dictionaryFromStudentForPost(aStudent:StudentInformation)-> String {
        var tempDict = NSMutableDictionary()
        tempDict["firstName"] = aStudent.firstName
        tempDict["lastName"] = aStudent.lastName
        tempDict["latitude"] = aStudent.latitude
        tempDict["longitude"] = aStudent.longitude
        tempDict["mapString"] = aStudent.mapString
        tempDict["mediaURL"] = aStudent.mediaURL
        tempDict["uniqueKey"] = "4913"
        
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
    
    static func compareStudents(stu1:StudentInformation, stu2:StudentInformation)->Int {
        if stu1.lastName == stu2.lastName &&
            stu1.firstName == stu2.firstName &&
            stu1.uniqueKey == stu2.uniqueKey &&
            stu1.latitude == stu2.latitude &&
            stu1.longitude == stu2.longitude &&
            stu1.mediaURL == stu2.mediaURL {
                //student exists
                return 2
        } else {
            if stu1.lastName == stu2.lastName &&
                stu1.firstName == stu2.firstName &&
                stu1.uniqueKey == stu2.uniqueKey {
                    //changing student info
                    return 1
            }
        }
        return 0
    }
    
    static func updateAllStudents(refStu: [StudentInformation], newStu:[StudentInformation], stuClosure: (stu1 : StudentInformation, stu2 : StudentInformation)->Int)->[StudentInformation] {
        //don't ever expect for refStu to have more items than newStu
        var updatedStu : [StudentInformation] = refStu
        
        //ugg, O(n^2) yeah I know...
        //it's starting to look like it was a huge mistake to have modeled StudentInformation after Villans structure, as it's a huge PITA to work with
        //since I can't use the power of dictionary updates since it's now encapsulated in StudentInformation, so I'm writing n^2
        //search to get around it (better ways there, but in reality, I'd re-write this stuff to fix StudentInformation)
        //it has however, provided a nice exercise in closures...
        for stu in newStu {
            var idx = 0
            var action = 0
            var status = 0
            var modify = 0
            if refStu.count == 0 {
                for stu in newStu {
                    updatedStu.append(stu)
                }
                return updatedStu
            } else {
                do {
                    status = stuClosure(stu1: stu , stu2: refStu[idx])
                    if status == 1 && action != -1 {
                        //modify student
                        modify = 1
                        action = idx
                        break
                    } else if status == 0 && action != -1 {
                        //add new student
                        modify = 2
                    } else {
                        //status == 2 : identical student exists, trumps other two
                        //take no action for this round
                        action = -1
                        modify = 0
                        break
                    }
                    idx++
                } while (refStu.count > idx)
            }
            //now act to update student after all have been checked
            if modify == 1 {
                //student info needs to be updated
                updatedStu[action].latitude = stu.latitude
                updatedStu[action].longitude = stu.longitude
                updatedStu[action].mediaURL = stu.mediaURL
                break
            }
            if modify == 2 {
                //new student, add to array of students
                updatedStu.append(stu)
                break
            }
        }
        return updatedStu
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
            "uniqueKey" : 0,
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