//
//  AppDelegate.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
//    func setupFirebaseLocalEmulator() {
//        var host = "127.0.0.1"
//        #if !targetEnvironment(simulator)
//        host = "192.168.68.111"
//        #endif
//        
//        let settings = Firestore.firestore().settings
//        settings.host = "\(host):8080"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//        
//        Storage.storage().useEmulator(withHost: host, port: 9199)
//    }
    

