//
//  AppDelegate.swift
//  industrialchronometer
//
//  Created by ulas özalp on 31.01.2022.
//

import UIKit

@main
 class AppDelegate: UIResponder, UIApplicationDelegate {

//https://www.appsdeveloperblog.com/customize-uinavigationbar-appearance-programmatically-via-appdelegate/
    
    
   var window: UIWindow?
    var viewControllers : [UIViewController]?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        
        
        //launch screen açılışta bekleme süresi

     Thread.sleep(forTimeInterval: 1)
   
        //red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
       
        //        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
//
//
//        let navItem = UINavigationItem(title: "SomeTitle")
////        // Override point for customization after application launch.
//
//        //tabbar activitiesred: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
//
//        //1 - create a window with the main screen dimensions
//        window = UIWindow(frame : UIScreen.main.bounds)
//
//        //2 - create storyboard. defaut story board
//
//
//
//        //3 integrate existing viewcontrollers into storyBoard
//
//       let tabBarController = TabBarViewController()
//        //tabBarController.viewControllers = viewControllers
//
//        // 5 make the tab bar controller the root view controller
//
//        window?.rootViewController = tabBarController
//        window?.makeKeyAndVisible()
//        
//
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        
        
    
        let navBarAppearance = UINavigationBarAppearance()
      
       
        
      navBarAppearance.configureWithOpaqueBackground()
       
                    navBarAppearance.backgroundColor = UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,.font : UIFont(name: "DS-Digital", size: 30.0)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,.font : UIFont(name: "DS-Digital", size: 32.0)]
        
                    UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).standardAppearance = navBarAppearance
                    UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).scrollEdgeAppearance = navBarAppearance
       
            
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
   

}

