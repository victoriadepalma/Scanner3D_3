//
//  InventoryListVM.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import FirebaseFirestore
import Foundation
import SwiftUI
import Firebase

class InventoryListViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []

    func listenToItems(appState: AppState, userId: String) async throws {
        guard !userId.isEmpty else {
            throw FirebaseError.noUserFound
        }

        Firestore.firestore().collection("items")
            .whereField("userId", isEqualTo: userId)
            .order(by: "name")
            .limit(toLast: 100)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print("Error fetching snapshot: \(error?.localizedDescription ?? "error")")
                    return
                }
                let docs = snapshot.documents
                let items = docs.compactMap {
                    try? $0.data(as: InventoryItem.self)
                }

                withAnimation {
                    self.items = items
                }
            }
    }
}
enum FirebaseError: Error {
    case noUserFound
}
