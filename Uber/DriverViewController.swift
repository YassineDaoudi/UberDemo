//
//  DriverViewController.swift
//  Uber
//
//  Created by Findl MAC on 27/07/2018.
//  Copyright © 2018 Yassine Daoudi. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class DriverViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    
    var driverLocation = CLLocationCoordinate2D()
    var riderLocation = CLLocationCoordinate2D()
    var riderEmail = ""
    var riderFullName = ""
    var riderPhoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameLabel.text = "Rider's Fullname : \(riderFullName)"
        phoneNumberLabel.text = "Rider's Phone Number : \(riderPhoneNumber)"
        emailLabel.text = "Rider's E-mail : \(riderEmail)"
        
        let requestCLLocation = CLLocation(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let PlaceMark = MKPlacemark(placemark: placemarks[0])
                    self.AddressLabel.text = "\(String(describing: PlaceMark.name!)),\(String(describing: PlaceMark.postalCode!)) \(String(describing: PlaceMark.locality!)), \(String(describing: PlaceMark.country!))"
                    print(PlaceMark)
                }
            }
        }
        
        let region = MKCoordinateRegion(center: riderLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = riderLocation
        annotation.title = riderFullName
        map.addAnnotation(annotation)
    }

    
    @IBAction func AcceptRequestButton(_ sender: Any) {
        // Update the ride Request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat" : self.driverLocation.latitude, "driverLong" : self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }

        // Give directions
        
        let requestCLLocation = CLLocation(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let PlaceMark = MKPlacemark(placemark: placemarks[0])
                    self.AddressLabel.text = "Rider's Address: \(String(describing: PlaceMark.name)), \(String(describing: PlaceMark.postalCode)) \(String(describing: PlaceMark.locality)), \(String(describing: PlaceMark.country))"
                    print(self.AddressLabel.text!)
                    let mapItem = MKMapItem(placemark: PlaceMark)
                    
                    mapItem.name = self.riderFullName
                    mapItem.phoneNumber = self.riderPhoneNumber
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                }
            }
        }
        
    }
    
}
