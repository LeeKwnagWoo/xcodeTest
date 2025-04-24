//
//  AppDelegate.swift
//  ReadMCC
//
//  Created by 이광우 on 2023/03/08.
//

import UIKit
import CoreTelephony

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CTTelephonyNetworkInfoDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        var telephonyNetworkInfo = CTTelephonyNetworkInfo()
//        telephonyNetworkInfo.delegate = self
//        telephonyNetworkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = { [weak telephonyNetworkInfo] carrierIdentifier in
//            let carrier: CTCarrier? = telephonyNetworkInfo?.serviceSubscriberCellularProviders?[carrierIdentifier]
//            if carrier?.mobileCountryCode == nil || carrier?.mobileNetworkCode == nil {
//                print("No SIM card detected or SIM card removed")
//                // 여기서 원하는 로직을 수행하면 됩니다.
//            } else {
//                print("SIM card detected")
//            }
//        }
        
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: NSNotification.Name("ShowPopup"), object: url.absoluteString)

           return true
    }
    


}

