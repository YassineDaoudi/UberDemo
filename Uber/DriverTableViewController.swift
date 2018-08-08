//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Findl MAC on 27/07/2018.
//  Copyright © 2018 Yassine Daoudi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            if let rideRequestsDictionary = snapshot.value as? [String:AnyObject] {
                  if let driverLatitude = rideRequestsDictionary["driverLatitude"] as? Double {
                    
                  } else {
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            driverLocation = coordinate
        }
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RiderCell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestsDictionary = snapshot.value as? [String:AnyObject] {
            if let email = rideRequestsDictionary["email"] as? String {
                if let longitude = rideRequestsDictionary["longitude"] as? Double  {
                    if let latitude = rideRequestsDictionary["latitude"] as? Double {
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                    }
                }
                
            }
            
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "showRiderInfo", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showRiderInfoVC = segue.destination as? DriverViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestsDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rideRequestsDictionary["email"] as? String {
                        if let longitude = rideRequestsDictionary["longitude"] as? Double  {
                            if let latitude = rideRequestsDictionary["latitude"] as? Double {
                                showRiderInfoVC.riderEmail = email
                                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                showRiderInfoVC.riderLocation = location
                                showRiderInfoVC.driverLocation = driverLocation
                                if let fullName = rideRequestsDictionary["fullname"] as? String  {
                                    if let phoneNumber = rideRequestsDictionary["phoneNumber"] as? String {
                                        showRiderInfoVC.riderFullName = fullName
                                        showRiderInfoVC.riderPhoneNumber = phoneNumber
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
