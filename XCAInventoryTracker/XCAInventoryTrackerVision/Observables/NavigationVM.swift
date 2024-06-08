//
//  NavigationVM.swift
//  XCAInventoryTrackerVision
//
//  Created by Victoria De Palma and Diana Silva
//

import Foundation
import SwiftUI

class NavigationViewModel: ObservableObject {
    
    @Published var selectedItem: InventoryItem?
    
    init(selectedItem: InventoryItem? = nil) {
        self.selectedItem = selectedItem
    }
}


