//
//  Login_Location_Pulled.swift
//  Herd
//
//  Created by Sid Verma on 7/6/17.
//  Copyright © 2017 Herd. All rights reserved.
//

import UIKit
import Hero
import CoreLocation

class Login_Location_Pulled: UIViewController {

    @IBOutlet var Herd_Welcome_Dialog_Container_View: UIView!
    @IBOutlet var Herd_Dialog_Image_View: UIImageView!
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Enables Hero for transitions
        self.isHeroEnabled = true
        Herd_Welcome_Dialog_Container_View.heroModifiers = [.translate(y:300)]
        
        self.Herd_Welcome_Dialog_Container_View.layer.cornerRadius = 8
        self.Herd_Welcome_Dialog_Container_View.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
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
