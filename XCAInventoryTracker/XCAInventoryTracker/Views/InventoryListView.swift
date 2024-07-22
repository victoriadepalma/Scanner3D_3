//
//  InventoryListView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva

import SwiftUI
import FirebaseAuth

struct InventoryListView: View {
    @StateObject var vm = InventoryListViewModel()
    @State private var items: [InventoryItem] = [] // Para almacenar los items
    @State private var formType: FormType?
    @State private var showAuthView = false
    @StateObject private var appState = AppState()
    @State private var userId: String = ""
    @State private var showEditProfileSheet = false
    @State private var showSignOutAlert = false
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 245/255, green: 245/255, blue: 245/255) // Color F5F5F5
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.items) { item in
                        InventoryListItemView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                formType = .edit(item)
                            }
                    }
                }
                .padding(.top, 50) // Ajustar el padding superior para evitar la superposición
                .padding()
            }
            .navigationBarItems(
                leading: NavigationLink(destination: HomeView()) {
                    Text("Home")
                },
                trailing: HStack {
                    Button(action: {
                        showEditProfileSheet.toggle()
                    }) {
                        Text("Edit Profile")
                    }
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        Text("Sign Out")
                    }
                    .alert(isPresented: $showSignOutAlert) {
                        Alert(
                            title: Text("Sign Out"),
                            message: Text("Are you sure you want to sign out?"),
                            primaryButton: .destructive(Text("Sign Out")) {
                                signOut()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Button("+ Item") {
                        formType = .add
                    }
                }
            )
            .sheet(isPresented: $showEditProfileSheet) {
                EditProfileView(userId: userId)
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
                        self.items = Array(vm.items.prefix(2)) // Tomar solo los primeros dos items
                    } catch {
                        print("Error fetching user ID or items: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Ocultar el título por defecto
        .overlay(
            VStack {
                HStack {
                    Text("My 3D Scans")
                        .font(.custom("SFProRounded-Bold", size: 32))
                        .padding(.leading, 16) // Ajustar el padding para separar del borde izquierdo
                        .padding(.top, 16) // Ajustar el padding superior para el espacio arriba del título
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        )
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
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

struct InventoryListItemView: View {
    let item: InventoryItem

    var body: some View {
        VStack {
            if let thumbnailURL = item.thumbnailURL {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .frame(width: 195, height: 275) // Adjusted height for the RoundedRectangle
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5) // Shadow only for the bottom part
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 175, height: 225) 
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        default:
                            ProgressView()
                        }
                    }
                    .frame(width: 175, height: 225)
                }
            }

            Text(item.name)
                .font(.custom("SFProRounded-Bold", size: 17))
                .multilineTextAlignment(.center) // Centrar el texto
            Text("Quantity: \(item.quantity)")
                .font(.custom("SFProRounded-Regular", size: 17))
                .multilineTextAlignment(.center) // Centrar el texto
        }
        .padding()
    }
}

struct InventoryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InventoryListView()
        }
    }
}
