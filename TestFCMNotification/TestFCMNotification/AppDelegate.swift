//
//  AppDelegate.swift
//  TestFCMNotification
//
//  Created by jaehwikim on 2/18/25.
//

import Foundation
import Firebase
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        Task {
            do {
                if try await notificationCenter.requestAuthorization(options: authOptions) == true {
                    print("@@@ Granted authorization: \(await notificationCenter.notificationSettings())")
                } else {
                    print("@@@ Denied authorization")
                }
            } catch {
                print("@@@ Error retrieving notification authorization")
            }
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("@@@ Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let deviceToken: [String: String] = ["token": fcmToken ?? ""]
        print("@@@ Device Token: \(deviceToken)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("@@@ Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        return [[.banner, .badge, .sound]]
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("@@@ Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        
        print(userInfo)
    }
}
