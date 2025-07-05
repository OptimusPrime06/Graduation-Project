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
        
        let vc1 = UINavigationController(rootViewController: MapViewController())
        let vc2 = UINavigationController(rootViewController: CarViewController())
        let vc3 = UINavigationController(rootViewController: ChatbotViewController())
        let vc4 = UINavigationController(rootViewController: SettingsViewController())
        let vc5 = UINavigationController(rootViewController: ProfileViewController())

        
        vc1.tabBarItem.image = UIImage(systemName: "map.fill")
        vc2.tabBarItem.image = UIImage(systemName: "car")
        vc3.tabBarItem.image = UIImage(systemName: "brain")
        vc4.tabBarItem.image = UIImage(systemName: "gearshape")
        vc5.tabBarItem.image = UIImage(systemName: "person.circle")

        
        vc1.title = "Map"
        vc2.title = "Live"
        vc3.title = "Chatbot"
        vc4.title = "Settings"
        vc5.title = "Profile"
        
        tabBar.tintColor = .label
        
        setViewControllers([vc1,vc2,vc3,vc4,vc5], animated: true)
    }

}
