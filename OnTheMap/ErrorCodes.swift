//
//  ErrorCodes.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 8/1/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import Foundation

struct ErrorCodes  {
    //authorization errors (100 series)
    let auth : [Int:String] = [
        100 :   "General network failure",
        101 :   "network not available",
        102 :   "no username entered",
        103 :   "account not found",
        104 :   "udacity failed to respond"
    ]
}