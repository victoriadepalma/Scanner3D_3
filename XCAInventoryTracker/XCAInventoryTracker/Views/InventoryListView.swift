//
//  InventoryListView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva

import SwiftUI
import FirebaseAuth


struct InventoryListView: View {
    @StateObject var vm = InventoryListViewModel()
      @State var formType: FormType?
      @State private var showAuthView = false
      @StateObject private var appState = AppState()
      @State private var userId: String = ""

    var body: some View {
        List {
            ForEach(vm.items) { item in
                InventoryListItemView(item: item)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        formType = .edit(item)
                    }
            }
        }
        .navigationTitle("Your 3D Scans")
     
        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    showAuthView.toggle()
//                }) {
//                    Text("Log In")
//                }
//            }
            ToolbarItem(placement: .navigationBarTrailing) {
                       Button(action: {
                           signOut()
                       }) {
                           Text("Sign Out")
                       }
                   }
            ToolbarItem(placement: .primaryAction) {
                Button("+ Item") {
                    formType = .add
                }
            }
        }
        .sheet(item: $formType) { type in
            NavigationStack {
                InventoryFormView(vm: .init(formType: type))
            }
            .presentationDetents([.fraction(0.85)])
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showAuthView) {
            NavigationStack {
                AuthView()
            }
        }
        .onAppear {
                 Task {
                     do {
                         userId = try await fetchUserId()
                         try await vm.listenToItems(appState: appState, userId: userId)
                     } catch {
                         print("Error fetching user ID or items: \(error.localizedDescription)")
                     }
                 }
             }
         }

         private func fetchUserId() async throws -> String {
             guard let currentUser = Auth.auth().currentUser else {
                 throw FirebaseError.noUserFound
             }
             return currentUser.uid
         }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            withAnimation {
                appState.userID = "" // Update the userID in the InventoryListViewModel
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct InventoryListItemView: View {
    
    let item: InventoryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                        }
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .frame(width: 150, height: 150)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
            }
        }
        
    }
    
}



#Preview {
    NavigationStack {
        InventoryListView()
    }
}
