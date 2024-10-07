import Foundation
import SwiftUI

class InventoryListViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    private var timer: Timer?

    // Function to start polling
    func listenToItems(appState: AppState, userId: String, token: String) {
        guard !userId.isEmpty else {
            print("No user found")
            return
        }

        // Start a timer that fires every X seconds (adjust the interval as needed)
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task {
                do {
                    try await self?.fetchItems(appState: appState, userId: userId, token: token)
                } catch {
                    print("Failed to fetch items: \(error.localizedDescription)")
                }
            }
        }
    }

    // Fetch the latest items from the backend
    func fetchItems(appState: AppState, userId: String, token: String) async throws {
        guard !userId.isEmpty else {
            throw FirebaseError.noUserFound
        }

        // Define the URL for your backend API
        let urlString = "https://scanner3d-backend.vercel.app/api/items"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Set the token in the header
        request.httpMethod = "GET"

        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
      
        // Check for a successful response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch items"])
        }
        
        // Decode the JSON response into your InventoryItem model
        do {
            let items = try JSONDecoder().decode([InventoryItem].self, from: data)
            DispatchQueue.main.async {
                print("Updating items on the main thread")
                self.items = items  // Update items on the main thread
            }
        } catch {
            print("Error decoding: \(error)") // This prints the specific error encountered
            throw error // Rethrow the error after printing it
        }
    }

    // Function to stop polling (e.g., when the view disappears)
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
}

enum FirebaseError: Error {
    case noUserFound
}
