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
    var userID : String? = nil
    
    var httpBody : [String : [String:String]] = [
        "udacity":[
            "username":"",
            "password":""
        ]
    ]
    
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
