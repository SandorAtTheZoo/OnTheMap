//
//  UserNWClient.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class UserNWClient : NSObject {
    
    var testData : Int? = nil
    
    override init() {
        super.init()
    }
    
    //TODO: add network call functions
    //sign in to udacity
    //add closure as return to return userID
    func authSignIn(urlString: String, httpBody : String, completionHandler: (success:Bool, errorString:String?)->Void) {
        
        /* 2. Build the URL */
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
      
        let session = NSURLSession.sharedSession()
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
                completionHandler(success: false, errorString: "Failed to connect to login server")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                println("new data : \(newData)")
                if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary {
                    
                    /* 6. Use the data! */
                    if let loggedIn = parsedResult["account"] as? NSDictionary {
                        //TODO: reference closure data here for pass by reference?
                        if let user = loggedIn["key"] as? String {
                            println("user ID : \(user)")
                            completionHandler(success: true, errorString: nil)
                        } else {
                            println("no user ID acquired")
                            completionHandler(success: false, errorString: "no user ID acquired")
                        }
                        
                    } else {
                        println("could not find account")
                        completionHandler(success: false, errorString: "could not find your account")
                    }
                } else {
                    println("couldn not bring in data from udacity")
                    completionHandler(success: false, errorString: "failed to get data from udacity")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    func logout(urlString: String, completionHandler: (success:Bool, errorString:String?)->Void) {
        //identify url
        let url = NSURL(string: urlString)!
        //configure request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {xsrfCookie = cookie}
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "failed to logout")
            } else {
                completionHandler(success: true, errorString: nil)
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
            println(NSString(data:newData, encoding:NSUTF8StringEncoding))
        }
        task.resume()
    }
    
//    /* Helper: Given raw JSON, return a usable Foundation object */
//    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
//        
//        var parsingError: NSError? = nil
//        
//        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
//        
//        if let error = parsingError {
//            completionHandler(result: nil, error: error)
//        } else {
//            completionHandler(result: parsedResult, error: nil)
//        }
//    }
    

    class func sharedInstance() -> UserNWClient {
        
        struct Singleton {
            static var userClient = UserNWClient()
        }
        
        return Singleton.userClient
    }
}