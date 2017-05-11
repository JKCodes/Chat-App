//
//  AppDelegate.swift
//  Chat App
//
//  Created by Joseph Kim on 4/11/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshCallBack), name: .firInstanceIDTokenRefresh, object: nil)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (_, _) in })
            
            FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: HomeController())
        
        return true
    }
    
    func tokenRefreshCallBack() {
        guard let uid = AuthenticationService.shared.currentId(), let refreshedToken = FIRInstanceID.instanceID().token() else { return }
        
        DatabaseService.shared.saveData(type: .user, data: [refreshedToken: 1 as AnyObject], firstChild: uid, secondChild: "notificationTokens", appendAutoId: false) { [weak self] (error, _) in
            if error != nil {
                print("Error while saving data")
            }
            
            self?.connectToFirebase()
        }
    }
    
    func connectToFirebase() {
        guard let _ = FIRInstanceID.instanceID().token() else { return }
        
        FIRMessaging.messaging().disconnect()
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect to Firebase")
            } else {
                print("Connected to Firebase.")
            }
        }
        
        
        FIRMessaging.messaging()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        connectToFirebase()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler()
    }
}

extension AppDelegate: FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}
