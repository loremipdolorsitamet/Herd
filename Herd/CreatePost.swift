//
//  CreatePost.swift
//  Herd
//
//  Created by Sid Verma on 7/11/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit

class CreatePost: UIViewController {

    @IBOutlet weak var postBody: UITextView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        
        let postBottonOnNavBar = UINavigationItem()
        let backButtonOnNavBar = UINavigationItem()
        postBottonOnNavBar.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postTapped))
        backButtonOnNavBar.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        postBottonOnNavBar.setRightBarButton(postBottonOnNavBar.rightBarButtonItem, animated: true)
        backButtonOnNavBar.setLeftBarButton(backButtonOnNavBar.leftBarButtonItem, animated: true)
        
        //Set Corner raduis for postBody layer
        postBody.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
    }
    
    func postTapped() {
        
        print("Post Tapped")
        
    }
    
    func backTapped(){
        
        print("Back Tapped")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Makes text field first responder hence opening keyboard
        postBody.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
