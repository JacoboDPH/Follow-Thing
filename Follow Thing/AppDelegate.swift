//
//  AppDelegate.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 17/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {

        print("willPresent")
        completionHandler([.badge, .alert, .sound])
    }
//
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {

        print("didReceive")
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("tes")
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let otherVC = sb.instantiateViewController(withIdentifier: "consejos") as! ConsejosViewController
//        window?.rootViewController = otherVC;
        
    }
//
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("tes")

//            let sb = UIStoryboard(name: "Main", bundle: nil)
//            let otherVC = sb.instantiateViewController(withIdentifier: "consejos") as! ConsejosViewController
//            window?.rootViewController = otherVC;
    }
//    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if response.actionIdentifier == "action" {
//
//            for victoria in 1...10 {
//                print("TOMALOOOOOOOO :::::: ",victoria)
//            }
//        }
//    }


    func registerForPushNotifications() {
        //1
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        UNUserNotificationCenter.current()
            //2
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                //3
                print("Permission granted: \(granted)")
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        
       
           
        // request permission from user to send notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
                UNUserNotificationCenter.current().delegate = self
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
            }
        })
        
    
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
       
        FirebaseApp.configure()

        return true
    }
//    func userNotificationCenter(
//      _ center: UNUserNotificationCenter,
//      didReceive response: UNNotificationResponse,
//      withCompletionHandler completionHandler: @escaping () -> Void) {
//      
//      defer { completionHandler() }
//
//      guard response.actionIdentifier ==
//          UNNotificationDefaultActionIdentifier else {
//        return
//      }
//      print("superPremio=====")
//      // Perform actions here
//    }
    @objc func appMovedToBackground() {
        print("App moved to background!")
        
        
       
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
       
        
       
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
       
    }
    func applicationWillResignActive(_ application: UIApplication) {
      
       print("*** entra de background")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        print("***va a background")
       
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Follow_Thing")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

