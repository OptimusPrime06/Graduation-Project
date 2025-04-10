//
//  MainTabBarViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: InformationViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        let vc3 = UINavigationController(rootViewController: HomeViewController())
        let vc4 = UINavigationController(rootViewController: CarViewController())
        let vc5 = UINavigationController(rootViewController: ProfileViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "info.circle.fill")
        vc2.tabBarItem.image = UIImage(systemName: "gearshape")
        vc3.tabBarItem.image = UIImage(systemName: "house")
        vc4.tabBarItem.image = UIImage(systemName: "car")
        vc5.tabBarItem.image = UIImage(systemName: "person.circle")
        
        vc1.title = "Information"
        vc2.title = "Settings"
        vc3.title = "Home"
        vc4.title = "Live"
        vc5.title = "Profile"
        
        
        
        tabBar.tintColor = .label
        
        setViewControllers([vc1,vc2,vc3,vc4,vc5], animated: true)
    }


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
