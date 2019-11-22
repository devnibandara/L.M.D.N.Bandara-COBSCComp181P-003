//
//  TabBarViewController.swift
//  NIBM Article
//
//  Created by Kithmal Bulathsinhala on 11/7/19.
//  Copyright © 2019 NIBM. All rights reserved.
//

import UIKit
import BiometricAuthentication

class TabBarViewController:  UITabBarController, UITabBarControllerDelegate{
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: ProfileViewController.self) {
            //print("dddddddddddddddddddd")
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Authentication required to access this section") { (result) in
                
                switch result {
                case .success( _):
                    print("Authentication Successful")
                    self.selectedIndex = 2
                case .failure(let error):
                    print("Authentication Failed")
                    
                }
            }
            return false
        }
        return true
        
    }
}
