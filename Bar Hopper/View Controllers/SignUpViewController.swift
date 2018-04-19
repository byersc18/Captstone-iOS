//
//  SignUpViewController.swift
//  Bar Hopper
//
//  Created by Cameron Byers on 3/23/18.
//  Copyright © 2018 Cameron Byers. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var retypePasswordTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Dismiss keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //set buttons to be rounded on the corners
        signUpButton.layer.cornerRadius = 20
        signUpButton.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dismiss keyboard from view
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
    
    //Dismiss keyboard when the done button on the keyboard is pressed
    @IBAction func retypePasswordDonePressed(_ sender: UITextField) {
        self.dismissKeyboard()
    }
    
    @IBAction func nameDonePressed(_ sender: UITextField) {
        self.dismissKeyboard()
    }
    
    
    //Takes user credentials and creates their account
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let retypePassword = retypePasswordTextField.text
        let name = nameTextField.text
        
        //check for strings in all text fields
        if email != "" && password != "" && retypePassword != "" && name != "" {
            let emailString: String = email as String!
            let passwordString: String = password as String!
            let retypePasswordString: String = retypePassword as String!
            let nameString: String = name as String!
            
            //check if passwords are the same
            if passwordString == retypePasswordString {
                //MAKE API CALL HERE
                let url = URL(string: "https://barhopperapi.herokuapp.com/api/signup")!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let postString = "email=" + emailString + "&password=" + passwordString + "&name=" + nameString + "&admin=false"
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        print(error!)
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print(response!)
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print(responseString!)
                }
                task.resume()
                
                performSegue(withIdentifier: "CreateAccountSegue", sender: self)
            }
            else {
                showAlertMessage(messageHeader: "Password don't Match", messageBody: "The password that you retyped does not match the origninal password.")
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
