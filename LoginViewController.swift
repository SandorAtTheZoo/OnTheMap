//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var authUsername: UITextField!
    @IBOutlet weak var authPassword: UITextField!
    @IBOutlet weak var authError: UILabel!
    
    var nwClient = UserNWClient()
    var appDelegate : AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
//        //debug studentInformation
//        let newStu = [
//            "createdAt" : "2015-02-24T22:27:14.456Z",
//            "firstName" : "NoOne",
//            "lastName" : "Johnson",
//            "latitude" : 28.5461248,
//            "longitude" : -82.95676799999999,
//            "mapString" : "Around",
//            "mediaURL" : "www.linkedin.com",
//            "objectId" : "kj18GEaWD8",
//            "uniqueKey" : 872458750,
//            "updatedAt" : "2015-03-09T22:07:09.593Z"
//        ]
//        let aStu = MapData.StudentInformation(dict:newStu)
//        
//        
//        println("stu:\(MapData.allUserInformation)")
//        MapData.allUserInformation.append(aStu)
//        for item in MapData.allUserInformation {
//            var info = item.lastName
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitLogin(sender: UIButton) {
        //TODO: call POST method for login, and handle error and status as closure
        nwClient.authSignIn(appDelegate.au.baseURL, httpBody: appDelegate.au.authUser(authUsername.text, pw: authPassword.text) as! String) {(success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
        //clear struct of name/pw
        appDelegate.au.authUser("", pw: "")
        //TODO: assign HTTPBody with blank info after login to clear struct fields
        
    }
    
    //TODO: create new account
    @IBAction func signUpNewAccount(sender: UIButton) {
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.authError.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! MapNavigationController
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.authError.text = errorString
            }
        })
    }

}