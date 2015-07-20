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
    
    var au = AuthUserData()
    var nwClient = UserNWClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitLogin(sender: UIButton) {
        //TODO: call POST method
        nwClient.authSignIn(au.baseURL, httpBody: au.authUser(authUsername.text, pw: authPassword.text) as! String, errorStatus: authError)
        //TODO: assign HTTPBody : trap out errors (no text in field)
        let httpBody = au.authUser(authUsername.text, pw: authPassword.text)
        //TODO: assign HTTPBody with blank info after login to clear struct fields
        
    }
    
    //TODO: create new account
    @IBAction func signUpNewAccount(sender: UIButton) {
    }
}