//
//  AppDelegate.swift
//  MiTokens
//
//  Created by Romain Penchenat on 05/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseAuth
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Gestion apparence
        UINavigationBar.appearance().barTintColor = UIColor(named: "Blue")
        application.statusBarStyle = .lightContent
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6024155085751040~8083296975")
        
        // Init Crashlytics
        Fabric.with([Crashlytics.self])
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { (result, error) in
            if let errorMsg = error?.localizedDescription {
                print(errorMsg)
            }
        }
        // Push
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                NotificationManager().notAuthorizedToSendNotifications()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager().setNotificationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "fr.romainpenchenat.MiTokens.NewAirdrop" {
            let tabBar = self.window!.rootViewController as! UITabBarController
            tabBar.dismiss(animated: false, completion: nil)
            tabBar.selectedIndex = 0
            NotificationCenter.default.post(name: NSNotification.Name.ShortcutNewAirdrop, object: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

