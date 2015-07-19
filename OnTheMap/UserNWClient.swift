//
//  UserNWClient.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation

class UserNWClient : NSObject {
    
    var testData : Int? = nil
    
    override init() {
        super.init()
    }
    
    //TODO: add network call functions
    //TODO: add data struct CALLED StudentInformation with user pin data
    //TODO: add remaining two panels for pin data
    

    class func sharedInstance() -> UserNWClient {
        
        struct Singleton {
            static var userClient = UserNWClient()
        }
        
        return Singleton.userClient
    }
}