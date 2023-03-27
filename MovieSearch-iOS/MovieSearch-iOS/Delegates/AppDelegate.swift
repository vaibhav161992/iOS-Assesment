//
//  AppDelegate.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 23/03/23.
//

import UIKit

protocol NetworkReachabilityProvider {
    var isNetworkReachable: Bool { get }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, NetworkReachabilityProvider {

    var isNetworkReachable: Bool = false
    
    static var shared: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get application delegate.")
        }
        return appDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let reachability = try! Reachability()
        self.isNetworkReachable = reachability.connection != .unavailable
        reachability.whenReachable = { reachability in
            self.isNetworkReachable = reachability.connection != .unavailable
        }
        reachability.whenUnreachable = { _ in
            self.isNetworkReachable = reachability.connection != .unavailable
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Unable to start notifier")
        }
        return true
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


}

