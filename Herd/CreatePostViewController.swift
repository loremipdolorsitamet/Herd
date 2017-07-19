//
//  PostViewViewController.swift
//  Herd
//
//  Created by Sid Verma on 7/18/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import SwiftDate
import FCAlertView

class CreatePostViewController: UIViewController, UITextViewDelegate, FCAlertViewDelegate {
    
    @IBOutlet weak var PostBody: UITextView!
    
    var charactersRemaing = UILabel()
    var viewAboveKeyboard = UIToolbar() //Creates toolbar view
    var charactersRemainingBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PostBody.delegate = self
        self.PostBody.returnKeyType = UIReturnKeyType.done
        self.updateCharacterCount()
        self.setUpTextView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //Handles setting up Text View and keyboard with it
    func setUpTextView() {
        
        PostBody.becomeFirstResponder() //Bring Up keyboard
        PostBody.layer.cornerRadius = 8 //Apply corner radius
        
        viewAboveKeyboard.sizeToFit()       //Sizes it accordingly
        viewAboveKeyboard.barTintColor = UIColor.white  //Colorize bar
        
        let plusButton: UIButton = UIButton.init(type: .custom) //Initiliazes custom button
        plusButton.setImage(UIImage(named: "Add Emoji"), for: .normal) //Sets plus button image
        plusButton.addTarget(self, action: #selector(self.plusButtonFromKeyboardTapped(sender:)), for: .touchUpInside) //Adds target
        plusButton.frame = CGRect(x: 0, y: 0, width: 35, height: 50) //Sizes button
        
        charactersRemaing.textColor = UIColor(red: 0.78, green: 0.94, blue: 0.81, alpha: 1)    //Colorize text color
        charactersRemaing.font = UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold)    //Stylize font
        charactersRemaing.frame = CGRect(x: 0, y: 0, width: 53, height: 100)   //Size "button"
        charactersRemainingBarButton = UIBarButtonItem(customView: charactersRemaing)   //Create bar button from "button"
        
        
        let plusBarButton = UIBarButtonItem(customView: plusButton) //Creates bar button item from button
        plusBarButton.imageInsets = UIEdgeInsetsMake(0, 0, 0, -10) //Assigns proper positioning of button
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //Create flexible space
        
        viewAboveKeyboard.items = [plusBarButton,spacer,charactersRemainingBarButton]   //Adds bar button item to tool bar
        PostBody.inputAccessoryView = viewAboveKeyboard //Adds tool bar to input accessory of PostBody
        
    }
    
    //Handles segue to adding emoji view
    @IBAction func plusButtonFromKeyboardTapped (sender: Any) {
        print("Plus Button Clicked.")
        //Hide Keyboard by endEditing or Anything you want.
        //self.view.endEditing(true)
    }
    
    
    func publishToDatabase() {
        
        //Get location data
        //Get current time in timeSince1970
        //Generate random post id from Firebase
        //
        
        if let locationLat = UserDefaults.standard.value(forKey: "current_location_lat") as? Double {
            if let locationLong = UserDefaults.standard.value(forKey: "current_location_long") as? Double {
                if let uid = UserDefaults.standard.value(forKey: "uid") as? String {
                    
                //Get current time
                let now = DateInRegion()
                let nowInternetDateTime = now.string(format: .iso8601(options: [.withInternetDateTime])) //Looks like this: 2017-07-18T16:12:53-07:00
                
                //Generated random post id and ref
                let postRef = Database.database().reference(withPath: "posts/").childByAutoId()
                let postUID = postRef.key
                
                //Post body text
                let postBodyText = self.PostBody.text
                
                //Geofire Reference
                let geofireRef = Database.database().reference(withPath: "post_locations/")
                let geoFire = GeoFire(firebaseRef: geofireRef)
                
                //User Reference
                let userRef = Database.database().reference(withPath: "users/").child(uid).child("posts")
                
                geoFire?.setLocation(CLLocation(latitude: locationLat, longitude: locationLong), forKey: postUID) { (error) in
                    if (error != nil) {
                        //Show an error message of some sorts
                        print("An error occured: \(error)")
                    } else {
                        
                        //Now that the post location is set let's write the post body to the post ref and to the users ref
                        
                        postRef.setValue(["body" : postBodyText,
                                          "timestamp" : nowInternetDateTime,
                                          "upvote" : 0,
                                          "downvote" : 0])
                        
                        userRef.updateChildValues([postUID:true])
                        
                        
                        }
                    }
                }
            }
        }
    }
    
    func updateCharacterCount() {
        self.charactersRemaing.text = "\((200) - self.PostBody.text.characters.count - 1)"  //Updates character count
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        updateCharacterCount()
        
        if (text == "\n"){
            
            let PostBodyText = PostBody.text
            let PostBodyTextNewLineRemoved = PostBodyText?.trimmingCharacters(in: CharacterSet.newlines)
            
            if !(PostBodyTextNewLineRemoved?.isEmpty)! {
                
            self.publishToDatabase()
            self.navigationController?.popViewController(animated: true)
                
            } else {
                
                let noTextInField = FCAlertView()
                
                noTextInField.cornerRadius = 8
                
                noTextInField.showAlert(inView: self, withTitle: "Nothing to post", withSubtitle: "Please add some text", withCustomImage: nil, withDoneButtonTitle: "Done", andButtons: ["Cancel"])
                
                PostBody.text = ""
                
            }
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= 200
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        
        if title == "Cancel" {
            print("cancel tapped")
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
