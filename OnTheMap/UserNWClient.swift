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
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let err = ErrorCodes()
    
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
                //network not available
                completionHandler(success: false, errorString: "could not complete request")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary {
                    
                    /* 6. Use the data! */
                    if let loggedIn = parsedResult["account"] as? NSDictionary {
                        //reference closure data here for pass by reference?
                        if let user = loggedIn["key"] as? String {
                            self.appDelegate.au.userID = user
                            completionHandler(success: true, errorString:nil)
                        } else {
                            println("no user ID acquired")
                            //no username entered
                            completionHandler(success: false, errorString:"no user ID entered")
                        }
                        
                    } else {
                        if let status = parsedResult["status"] as? Int {
                            if status == 400 || status == 403 {
                                if let errStr = parsedResult["error"] as? String {
                                    completionHandler(success: false, errorString: errStr)
                                } else {
                                    completionHandler(success: false, errorString: "login failed, no error description")
                                }
                            } else {
                                completionHandler(success: false, errorString: "login error, unknown error code")
                            }
                        } else {
                            completionHandler(success: false, errorString: "login error, no status")
                        }
                    }
                } else {
                    println("couldn not bring in data from udacity")
                    completionHandler(success: false, errorString:"no data returned from udacity")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    func authGetInfo(completionHandler: (userDictionary: NSDictionary?, success:Bool, errorString:String?)->Void) {
        //build URL
        var urlString = appDelegate.au.getInfoURL + appDelegate.au.userID!
        println("urlString : \(urlString)")
        let url = NSURL(string: urlString)!
        
        //configure and make request
        var parsingError : NSError?
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, getError) in
            if let error = getError {
                completionHandler(userDictionary: nil, success: false, errorString: "failed to connect to server")
            } else {
                //parse data
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                if let dataResult = NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments, error: &parsingError) as? NSDictionary {
                    if let userData = dataResult["user"] as? NSDictionary {
                        completionHandler(userDictionary: userData, success: true, errorString: nil)
                    } else {
                        completionHandler(userDictionary: nil, success: false, errorString: "failed to find user")
                    }
                } else {
                    completionHandler(userDictionary: nil, success: false, errorString: "no parsable JSON")
                }
            }
        })
        //start request
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
    
    func getStudentLocations(completionHandler:(success:Bool, errorString:String?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){data, response, error in
            if error != nil {
                println("failed in parse call")
            }
            //println(NSString(data: data , encoding: NSUTF8StringEncoding))
            var parseError : NSError? = nil
            if let locs = NSJSONSerialization.JSONObjectWithData(data , options: NSJSONReadingOptions.AllowFragments, error: &parseError) as? NSDictionary {
                if let users = locs.valueForKey("results") as? [[String:AnyObject]] {
                    MapData.addStudentInformation(users)
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "failed to parse users from results")
                }
            } else {
                completionHandler(success: false, errorString: "failed to parse data from Parse")
            }
        }
        task.resume()
    }
    //Parse function call
    func postStudentLocation(httpBody:String, completionHandler:(success:Bool, errorString:String?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                //handle error
                completionHandler(success: false, errorString: "Failed to POST student data to server")
            } else {
                completionHandler(success: true, errorString: nil)
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
            }
            
        }
        task.resume()
    }
    //Parse function call to update user info
    func putStudentLocation(httpBody:String, completionHandler:(success:Bool, errorString:String?)->Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/" + appDelegate.au.parse_objectID
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                //handle error
                completionHandler(success: false, errorString: "Failed to PUT student data to server")
            } else {
                completionHandler(success: true, errorString: nil)
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
            }
            
        }
        task.resume()
        
    }
    class func sharedInstance() -> UserNWClient {
        
        struct Singleton {
            static var userClient = UserNWClient()
        }
        
        return Singleton.userClient
    }
}