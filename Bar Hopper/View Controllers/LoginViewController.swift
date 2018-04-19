//
//  LoginViewController.swift
//  Bar Hopper
//
//  Created by Cameron Byers on 3/23/18.
//  Copyright © 2018 Cameron Byers. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var rememberMeSwitch: UISwitch!
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Dismiss keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //request for permission to use gps
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        //set buttons to be rounded on the corners
        logInButton.layer.cornerRadius = 20
        logInButton.layer.borderWidth = 1
        
        signUpButton.layer.cornerRadius = 20
        signUpButton.layer.borderWidth = 1
        
        //if remember me switch is on fill in fields
        let mySwitch = UserDefaults.standard.object(forKey: "switch")
        if mySwitch != nil {
            let mySwitchString = mySwitch as! String
            if mySwitchString == "true" {
                let myEmail: String = UserDefaults.standard.object(forKey: "email") as! String
                let myPassword: String = UserDefaults.standard.object(forKey: "password") as! String
                rememberMeSwitch.setOn(true, animated: true)
                emailTextField.text = myEmail
                passwordTextField.text = myPassword
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mySwitch = UserDefaults.standard.object(forKey: "switch")
        if mySwitch != nil {
            let mySwitchString = mySwitch as! String
            if mySwitchString == "true" {
                self.performSegue(withIdentifier: "LoginSegue", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dismiss the keyboard from view
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Dismiss keyboard when the done button on the keyboard is pressed
    @IBAction func emailDonePressed(_ sender: UITextField) {
        self.dismissKeyboard()
    }
    
    //Dismiss keyboard when the done button on the keyboard is pressed
    @IBAction func passwordDonePressed(_ sender: UITextField) {
        self.dismissKeyboard()
    }
    

    
    
    func loginRequest(email: String, password: String) -> Bool {
        //MAKE API CALL HERE
        var returnBool: Bool = false
        let url = URL(string: "https://barhopperapi.herokuapp.com/api/authenticate")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=" + email + "&password=" + password
        request.httpBody = postString.data(using: .utf8)
        let semaphore = DispatchSemaphore(value: 0) //Use semaphore to make httprequest synchronous
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print(error!)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print(responseString!)
            
            //parse return data
            let tempData: Data = data
            let myDict: NSDictionary = (try! JSONSerialization.jsonObject(with: tempData, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            var responseJson = [String: AnyObject]()
            responseJson = myDict as! Dictionary
            
            let success: Bool = responseJson["success"]! as! Bool
            
            //if login passes segue to next view and save token and desc_id
            if success {
                //save token and desc_id to memory
                if let token = (responseJson["token"]! as? String)
                {
                    UserDefaults.standard.set(token, forKey: "token")
                }
                if let desc_id = (responseJson["desc_id"]! as? String)
                {
                    UserDefaults.standard.set(desc_id, forKey: "desc_id")
                }
                
                returnBool = true
            }
            else {
                returnBool = false
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return returnBool
    }
    
    //Checks if user credentials are correct and if they are correct log them in. If incorrect display error message.
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        //check for string for the email and password
        if email != "" && password != "" {
            let emailString: String = email as String!
            let passwordString: String = password as String!
            
            let request: Bool = loginRequest(email: emailString, password: passwordString)
            
            if request {
                //if remember me is toggled on save email and password
                if rememberMeSwitch.isOn {
                    UserDefaults.standard.set(emailString, forKey: "email")
                    UserDefaults.standard.set(passwordString, forKey: "password")
                    UserDefaults.standard.set("true", forKey: "switch")
                }
                else {
                    UserDefaults.standard.set("", forKey: "email")
                    UserDefaults.standard.set("", forKey: "password")
                    UserDefaults.standard.set("false", forKey: "switch")
                }
                
                self.performSegue(withIdentifier: "LoginSegue", sender: self)
            }
            else {
                showAlertMessage(messageHeader: "Login Failed", messageBody: "Your email password combination are incorrect.")
            }
        }
        else {
            showAlertMessage(messageHeader: "Missing Information", messageBody: "One or more of the text fields is missing information.")
        }
        
    }
    
    //Displays alert messages with specific messages
    func showAlertMessage(messageHeader header: String, messageBody body: String) {
        
        let alertController = UIAlertController(title: header, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    

}
