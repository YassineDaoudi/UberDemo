//
//  ViewController.swift
//  Uber
//
//  Created by Findl MAC on 26/07/2018.
//  Copyright © 2018 Yassine Daoudi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class ViewController: UIViewController {
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passworTextField: UITextField!
    @IBOutlet weak var userTypeSwitch: UISwitch!
    @IBOutlet weak var signupOrLoginButton: UIButton!
    @IBOutlet weak var actionChangeButton: UIButton!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var signUpMode = true
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        
        
    }
    
    @IBAction func signupOrLoginButton(_ sender: Any) {
        
        
        
        
        if emailTextfield.text == "" || passworTextField.text == "" || phoneTextField.text == "" || fullNameTextField.text == ""
        {
            displayAlert(title: "Missing Information", message: "Please make sure to provide all the data")
        } else {
            if let email = emailTextfield.text {
                if let password = passworTextField.text {
                    if let fullname = fullNameTextField.text {
                        if let phoneNumber = phoneTextField.text {
                            if signUpMode {
                                //Sign Up
                               
                                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                                    if error != nil {
                                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                                    } else {
                                        if self.userTypeSwitch.isOn {
                                            // Driver
                                            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                                                snapshot.ref.updateChildValues(["fullName" : fullname, "phoneNumber" : phoneNumber])
                                                Database.database().reference().child("RideRequests").removeAllObservers()
                                            }
                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                            req?.displayName = "Driver"
                                            req?.commitChanges(completion: nil)
                                        
                                            self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                        } else {
                                            // Rider
                                            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                                                snapshot.ref.updateChildValues(["fullname" : fullname, "phoneNumber" : phoneNumber])
                                                Database.database().reference().child("RideRequests").removeAllObservers()
                                            }
                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                            req?.displayName = "Rider"
                                            req?.commitChanges(completion: nil)
                                            self.performSegue(withIdentifier: "riderSegue", sender: nil) //{
//                                                if let fullName = fullname as? String  {
//                                                    if let phoneNumber = phoneNumber as? String {
//                                                        showRiderInfoVC.riderFullName = fullName
//                                                        showRiderInfoVC.riderPhoneNumber = phoneNumber
//                                                    }
//                                                }
//                                            }
                                        }
                                    }
                                }
                            } else {
                                //Log In
                                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                                    if error != nil {
                                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                                    } else {
                                        if user?.displayName == "Driver" {
                                            // Driver
                                            self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                        } else {
                                            // Rider
                                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title:String, message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func actionChangeButton(_ sender: Any) {
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
        if signUpMode {
            signupOrLoginButton.setTitle("Log In", for: .normal)
            actionChangeButton.setTitle("Sign Up", for: .normal)
            driverLabel.isHidden = true
            riderLabel.isHidden = true
            userTypeSwitch.isHidden = true
            fullNameTextField.isHidden = true
            phoneTextField.isHidden = true
            
            signUpMode = false
        } else {
            signupOrLoginButton.setTitle("Sign Up", for: .normal)
            actionChangeButton.setTitle("Log In", for: .normal)
            driverLabel.isHidden = false
            riderLabel.isHidden = false
            userTypeSwitch.isHidden = false
            fullNameTextField.isHidden = false
            phoneTextField.isHidden = false
            signUpMode = true
        }
        
    }
    
    
}

