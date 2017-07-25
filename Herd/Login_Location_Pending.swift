//
//  Login_Location_Pending.swift
//  
//
//  Created by Sid Verma on 7/6/17.
//
//

import UIKit
import Hero
import SwiftLocation
import CoreLocation
import GeoFire
import FirebaseDatabase


class Login_Location_Pending: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var Herd_Dialog_Image_View: UIImageView!
    var locationManager: CLLocationManager!
    var locationToSeque = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         
         Upon viewload, locationManager is assigned approriate delegate and asks for user's permission for location 
         SwiftLocation is then used to pull the user's location and set in UserDefaults
         
        */
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        Location.getLocation(accuracy: .neighborhood, frequency: .oneShot, success: { (_, location) in
            print("Successfully pulled location:  \(location)")
            self.locationToSeque = location
            //Store Location into UserDefaults
            let defaults = UserDefaults.standard
            defaults.setValue(Double(location.coordinate.latitude), forKey: "current_location_lat")
            defaults.setValue(Double(location.coordinate.longitude), forKey: "current_location_long")
            defaults.set(true, forKey: "authd")
            
            //Checking if user's location is within 2 miles of a school
            let geofireRef = Database.database().reference(withPath: "school_location/")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            
            var circleQuery = geoFire?.query(at: location, withRadius: 2.0)
            
            var circleQueryHandler = circleQuery?.observe(.keyEntered, with: {(key: String!, location : CLLocation!) in
            
                print("VVVVVVVVVVV------PRINTING KEY BELOW----------VVVVVVVVVVVV")
                print(key)
                
                
                
                if key.isEmpty || key == nil{
                 
                    //
                
                } else {
                    
                    //Show an message saying you cant use this in schools
                    self.performSegue(withIdentifier: "toLocationSuccess", sender: nil)
                    
                }
            })
            
            circleQuery?.observeReady({
            
                print("READY!!")
            
            })
            
        }) { (request, last, error) in
            request.cancel() // stop continous location monitoring on error
            print("Location monitoring failed due to an error \(error)")
        }
        
        //self.performSegue(withIdentifier: "toLocationSuccess", sender: nil)
        

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocationSuccess" {
            let destinationVC = segue.destination as! Login_Location_Pulled
            destinationVC.location = locationToSeque
        }
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
