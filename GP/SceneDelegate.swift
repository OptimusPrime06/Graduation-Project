//
//  SceneDelegate.swift
//  GP
//
//  Created by Gulliver Raed on 3/3/25.
//

import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        if Auth.auth().currentUser != nil {
            showMainScreen()
        } else {
            showLoginScreen()
        }
        
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Navigation Helpers
    
    func showLoginScreen() {
        let loginVC = LogInViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = navController
    }
    
    func showMainScreen() {
        let mainTabBar = MainTabBarViewController()
        window?.rootViewController = mainTabBar
    }
    
    // MARK: - Lifecycle (default stubs)
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}


