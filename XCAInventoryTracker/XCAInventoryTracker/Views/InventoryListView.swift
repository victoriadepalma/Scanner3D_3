//
//  InventoryListView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct InventoryListView: View {
    @StateObject var vm = InventoryListViewModel()
    @State private var items: [InventoryItem] = []
    
    @State private var formType: FormType?
    @State private var showAuthView = false
    @AppStorage("uid") var userID: String = ""
    @AppStorage("token") var token: String = ""
    @StateObject private var appState = AppState()
    @State private var userId: String = ""
    @State private var idToken: String = ""
    @State private var showTutorial = false
    @State private var showEditProfileSheet = false
    
    @State private var showSignOutAlert = false
    @State private var showMenu = false // State to show/hide the menu

    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack { // Use ZStack to layer the main content and the slide-in menu
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Upper Rectangle
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color(red: 243/255, green: 239/255, blue: 227/255))
                                .cornerRadius(10)
                                .frame(width: geometry.size.width * 0.9, height: 131)
                                .overlay(
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Capture Your")
                                                .font(.custom("SFProRounded-Bold", size: 25))
                                                .foregroundColor(Color(red: 5/255, green: 4/255, blue: 4/255))
                                            Text("World in 3D")
                                                .font(.custom("SFProRounded-Bold", size: 25))
                                                .foregroundColor(Color(red: 5/255, green: 4/255, blue: 4/255))
                                        }
                                        .padding(.leading, 20)

                                        Spacer()

                                        Image("sofa")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 160, height: 146)
                                            .padding(.trailing, 20)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                )
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                        }
                        .frame(height: 131)

                        Spacer().frame(height: 30)

                        HStack {
                            Spacer(minLength: 20)
                            Button(action: {
                                formType = .add
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 233/255, green: 233/255, blue: 233/255), lineWidth: 1)
                                        )

                                    Image("mas")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .padding(.trailing, 20)
                        }

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
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                        }
                    }
                    .background(Color(red: 248/255, green: 247/255, blue: 243/255))
                    .frame(minHeight: UIScreen.main.bounds.height)
                }
                .navigationBarItems(
                    trailing: Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image("menu")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .opacity(showMenu ? 0 : 1) // Hide the menu button when the menu is shown
                )
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
                .sheet(isPresented: $showEditProfileSheet) {
                    EditProfileView(userId: userId)
                }
                .sheet(isPresented: $showTutorial) {
                                Tutorial()
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
                .onAppear() {

                    Task {
                        do {
                            print("ESTOY ENTRANDO")
                            userId = try await fetchUserId()
                            idToken=try await fetchUserToken()
                            try await vm.fetchItems(appState: appState, userId: userId, token: idToken)
                            try await vm.listenToItems(appState: appState, userId: userId, token: idToken)
                            print("YA ENTRE")
                            self.items = vm.items
                        } catch {
                            print("Error fetching user ID or items: \(error.localizedDescription)")
                        }
                    }
                }
                .onDisappear(){
                    Task {
                        do {
                            print("ESTOY SALIENDO")
                            vm.stopPolling()
                            
            
                        } catch {
                            print("Error fetching user ID or items: \(error.localizedDescription)")
                        }
                    }
                }
           
            }
          
                
            
            
            .navigationBarTitleDisplayMode(.inline)

            if showMenu {
                SlideInMenuView(showMenu: $showMenu, showEditProfileSheet: $showEditProfileSheet,showTutorial: $showTutorial,showSignOutAlert: $showSignOutAlert)
                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height)
                    .transition(.move(edge: .trailing))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    withAnimation {
                                        showMenu = false
                                    }
                                }
                            }
                    )
            }
        }
    }

    private func fetchUserId() async throws -> String {
//        guard let currentUser = Auth.auth().currentUser else {
//            throw FirebaseError.noUserFound
//        }
//        return currentUser.uid
        return userID
    }
    
    private func fetchUserToken() async throws -> String {
//        guard let currentUser = Auth.auth().currentUser else {
//            throw FirebaseError.noUserFound
//        }
//        return currentUser.uid
        return token
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            withAnimation {
                appState.userID = ""
                userID = ""
                token = ""
            }
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

struct SlideInMenuView: View {
    @Binding var showMenu: Bool
    @Binding var showEditProfileSheet: Bool
    @Binding var showTutorial: Bool
    @Binding var showSignOutAlert: Bool
    @AppStorage("token") var token: String = ""
    @State private var profileImageURL: URL?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = "" // Added state for email

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    // Profile image
                    if let profileImageURL = profileImageURL {
                        AsyncImage(url: profileImageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: profileImageDiameter, height: profileImageDiameter)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: profileImageDiameter, height: profileImageDiameter)
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: profileImageDiameter, height: profileImageDiameter)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(firstName) \(lastName)")
                            .font(.custom("SFProRounded-Bold", size: 25))
                            .lineLimit(1)

                        Text(email) // Display email below the name
                            .font(.custom("SFProRounded-Regular", size: 17))
                            .foregroundColor(Color(red: 193/255, green: 193/255, blue: 193/255)) // Set color to C1C1C1
                            .lineLimit(1)
                    }
                    .padding(.top, 5) // Adjust space between name and email
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding()

            // Menu Options
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    showEditProfileSheet.toggle()
                    withAnimation {
                        showMenu.toggle()
                    }
                }) {
                    HStack {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: min(UIScreen.main.bounds.width * 0.1, 35),
                                   height: min(UIScreen.main.bounds.width * 0.1, 35))
                          
                        Text("My Profile")
                            .font(.custom("SFProRounded-Bold", size: 20))
                            .foregroundColor(Color(red: 239/255, green: 198/255, blue: 177/255)) // EFC7B1
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(5)
                }

                
                Button(action: {
                    // Navigate to My Scans
                    withAnimation {
                        showMenu.toggle()
                    }
                }) {
                    HStack {
                        Image("items")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(UIScreen.main.bounds.width * 0.1, 32),
                                   height: min(UIScreen.main.bounds.width * 0.1, 32)) // Adapt size based on screen width

                        Text("My Scans")
                            .font(.custom("SFProRounded-Bold", size: 20))
                            .foregroundColor(Color(red: 239/255, green: 198/255, blue: 177/255)) // EFC7B1
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(5)
                }
                
                Button(action: {
                    // Acción para mostrar el tutorial
                    withAnimation {
                        showMenu.toggle()
                        showTutorial = true
                    }
                }) {
                    HStack {
                        Image("ajustes")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(UIScreen.main.bounds.width * 0.1, 32),
                                   height: min(UIScreen.main.bounds.width * 0.1, 32))
                    Text("How to Use?")
                        .font(.custom("SFProRounded-Bold", size: 20))
                        .foregroundColor(Color(red: 239/255, green: 198/255, blue: 177/255)) // EFC7B1
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(5)
                }
                
                
          
                
                Button(action: {
                    showSignOutAlert = true
                    withAnimation {
                        showMenu.toggle()
                    }
                }) {
                    HStack {
                        Image("logOut")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(UIScreen.main.bounds.width * 0.1, 32),
                                   height: min(UIScreen.main.bounds.width * 0.1, 32))
                    Text("Log Out")
                        .font(.custom("SFProRounded-Bold", size: 20))
                        .foregroundColor(Color(red: 239/255, green: 198/255, blue: 177/255)) // EFC7B1
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(5)
                }
                Spacer()
            }
            .padding()

            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height)
        .background(Color(red: 248/255, green: 247/255, blue: 243/255)) // F8F7F3
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 233/255, green: 233/255, blue: 233/255), lineWidth: 1) // E9E9E9
        )
        .shadow(radius: 5)
        .padding(.top, 50)
        .padding(.trailing, -UIScreen.main.bounds.width * 0.25)
        .onAppear {
            Task {
                do {
                    try await fetchProfileImageURL()
                    try await fetchUserProfile()
                } catch {
                    print("Error fetching user profile or image URL: \(error.localizedDescription)")
                }
            }
        }
    }
    private func fetchUserToken() async throws -> String {
//        guard let currentUser = Auth.auth().currentUser else {
//            throw FirebaseError.noUserFound
//        }
//        return currentUser.uid
        return token
    }
    
    private func fetchProfileImageURL() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        print(userId)
//        let db = Firestore.firestore()
//        let userDocRef = db.collection("users").document(userId)
//        
//        userDocRef.getDocument { document, error in
//            if let document = document, document.exists {
//                let data = document.data()
//                self.profileImageURL = URL(string: data?["profileImageURL"] as? String ?? "")
//            } else {
//                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
    }
    
    private func fetchUserProfile() async throws {
        print("Hola", token)
        
        // Fetch user profile from the API
        let urlString = "https://scanner3d-backend.vercel.app/api/users"
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
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user profile"])
        }

        // Decode the JSON response into a User model
        do {
            let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
            self.firstName = userProfile.firstname
            self.lastName = userProfile.lastname
            self.email = userProfile.email
            print("IMAGE",userProfile.profileImageUrl)
            self.profileImageURL = URL(string: userProfile.profileImageUrl as? String ?? "")
//            self.profileImageURL = userProfile.profileImageURL
        } catch {
            print("Error decoding: \(error)") // This prints the specific error encountered
            throw error // Rethrow the error after printing it
        }
    }

    // Example UserProfile model
    struct UserProfile: Codable {
        let firstname: String
        let lastname: String
        let email: String
        let profileImageUrl: String?
    }

    private var profileImageDiameter: CGFloat {
        min(UIScreen.main.bounds.width * 0.15, 80) // Adapt size based on screen width
    }
}







struct InventoryListItemView: View {
    let item: InventoryItem

    var body: some View {
        VStack {
            if let thumbnailURL = item.thumbnailURL {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 186, height: 212)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 233/255, green: 233/255, blue: 233/255), lineWidth: 1)
                        )
                    VStack {
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            default:
                                ProgressView()
                            }
                        }
                        .frame(width: 140, height: 140)
                        Text(item.name)
                            .font(.custom("SFProRounded-Bold", size: 17))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
}

struct InventoryListView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryListView()
    }
}
