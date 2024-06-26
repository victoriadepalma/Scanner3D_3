//
//  XCAInventoryTrackerVisionApp.swift
//  XCAInventoryTrackerVision
//
//  Created by Victoria De Palma and Diana Silva
//

import SwiftUI

@main
struct XCAInventoryTrackerVisionApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var navVM = NavigationViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                InventoryListView()
                    .environmentObject(navVM)
            }
        }
        
        WindowGroup(id: "item") {
            InventoryItemView().environmentObject(navVM)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
    }
}
