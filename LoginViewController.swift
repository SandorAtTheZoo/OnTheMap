//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Christopher Johnson on 7/18/15.
//  Copyright (c) 2015 Christopher Johnson. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate {
    
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
        
        authPassword.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitLogin(sender: UIButton) {
        startLogin()
    }
    
    //TODO: create new account
    @IBAction func signUpNewAccount(sender: UIButton) {
        //add call to browser here
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "http://www.udacity.com")!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        startLogin()
        textField.resignFirstResponder()
        return true
    }
    
    func startLogin() {
        //call POST method for login, and handle error and status as closure
        nwClient.authSignIn(appDelegate.au.baseURL, httpBody: appDelegate.au.authUser(authUsername.text, pw: authPassword.text) as! String) {(success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
        //clear struct of name/pw
        appDelegate.au.authUser("", pw: "")
        
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