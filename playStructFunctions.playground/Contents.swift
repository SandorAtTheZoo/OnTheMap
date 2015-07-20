//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


struct AuthData {

    var httpBody : [String : [String:String]] = [
        "udacity" : [
            "username" : "",
            "password":""
        ]
    ]
    
    mutating func authUser (uname : String, pw : String) -> [String : [String:String]] {
        var userData = httpBody["udacity"]!
        userData["username"] = uname
        userData["password"] = pw
        httpBody["udacity"] = userData
        return httpBody
        
    }
    
}

var au = AuthData()

var auth = au.authUser("help", pw: "me")

var auth2 = "\(auth)"

var auth3 = NSJSONSerialization.dataWithJSONObject(auth, options: NSJSONWritingOptions.PrettyPrinted, error: nil)


var my : NSString = NSString(data: auth3!, encoding: NSUTF8StringEncoding)!