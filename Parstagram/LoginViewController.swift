//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Joy Paul on 3/19/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passField.text
        
        user.signUpInBackground { (success, error) in
            success ? self.performSegue(withIdentifier: "onsignin", sender: nil) : print("Couldn't signup \(error?.localizedDescription)")
        }
    }
    
    @IBAction func onSignIn(_ sender: UIButton) {
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passField.text!) { (user, error) in
            user != nil ? self.performSegue(withIdentifier: "onsignin", sender: nil) : print("Error logging in \(error?.localizedDescription)")
        }
    }
    
    

}
