//
//  AuthUserData.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/19/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation

struct AuthUserData {
    let baseURL = "https://www.udacity.com/api/session"
    let getInfoURL = "https://www.udacity.com/api/users/"
    var userID : String? = nil
    //added these variables to support the Parse PUT method to update user info
    var parse_objectID : String = ""
    
    var httpBody : [String : [String:String]] = [
        "udacity":[
            "username":"",
            "password":""
        ]
    ]
    
    //I think I put this in here when I was trying to pass this struct around rather than
    //declaring it in appDelegate and referencing variables from there, but it's kinda neat
    //so I'll leave it...
    //http://stackoverflow.com/questions/24035648/swift-and-mutating-struct
    mutating func authUser (uname : String, pw : String) -> NSString {
        var userData = httpBody["udacity"]!
        userData["username"] = uname
        userData["password"] = pw
        httpBody["udacity"] = userData
        
        var convData = NSJSONSerialization.dataWithJSONObject(httpBody, options: nil, error: nil)
        var finalData : NSString = NSString(data: convData!, encoding: NSUTF8StringEncoding)!
        
        return finalData
        
    }
}
