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
    func authSignIn(urlString: String, httpBody : String, errorStatus : UILabel) {
        
        /* 2. Build the URL */
        let url = NSURL(string: urlString)!
        
        println("url :\(urlString)")
        println("httpBody : \(httpBody)")
        
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
                dispatch_async(dispatch_get_main_queue()) {
                    errorStatus.text = "Failed to connect to login server"
                }
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
                        }
                        
                    }
                } else {
                    println("couldn not bring in data from udacity")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    
    

    class func sharedInstance() -> UserNWClient {
        
        struct Singleton {
            static var userClient = UserNWClient()
        }
        
        return Singleton.userClient
    }
}