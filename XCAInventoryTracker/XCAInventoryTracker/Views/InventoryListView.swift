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
        NavigationStack {
            VStack(spacing: 0) {
                // Rectángulo superior
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color(red: 243/255, green: 239/255, blue: 227/255)) // Color F3EFE3
                        .cornerRadius(10)
                        .frame(width: geometry.size.width * 0.9, height: 131) // Tamaño responsive
                        .overlay(
                            HStack {
                                VStack(alignment: .leading, spacing: 2) { // Espacio reducido entre los textos
                                    Text("Capture Your")
                                        .font(.custom("SFProRounded-Bold", size: 25))
                                        .foregroundColor(Color(red: 5/255, green: 4/255, blue: 4/255)) // Color 050404
                                    Text("World in 3D")
                                        .font(.custom("SFProRounded-Bold", size: 25))
                                        .foregroundColor(Color(red: 5/255, green: 4/255, blue: 4/255)) // Color 050404
                                }
                                .padding(.leading, 20) // Padding para el texto dentro del rectángulo
                                
                                Spacer() // Espacio flexible que empuja el contenido hacia la izquierda

                                Image("sofa") // Imagen desde los Assets
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Ajuste de aspecto de la imagen
                                    .frame(width: 160, height: 146) // Tamaño de la imagen ajustado
                                    .padding(.trailing, 20) // Padding desde el borde derecho del rectángulo
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Alineación y tamaño
                        )
                        .padding(.top, 20) // Espacio desde la parte superior de la pantalla
                        .padding(.horizontal, 20) // Espacio desde los lados de la pantalla
                }
                .frame(height: 131) // Asegura que la altura esté bien definida
                
                // Espacio adicional para separar el botón del rectángulo
                Spacer().frame(height: 30) // Ajusta la altura según sea necesario
                
                // Botón "+ Item"
                HStack {
                    // Espacio flexible reducido para mover el botón a la izquierda
                    Spacer(minLength: 20)
                    Button(action: {
                        formType = .add
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50) // Tamaño del botón circular
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 233/255, green: 233/255, blue: 233/255), lineWidth: 1) // Borde en color E9E9E9
                                )
                            
                            Image("mas") // Imagen de assets llamada "mas"
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24) // Tamaño reducido de la imagen
                        }
                    }
                    .padding(.trailing, 20) // Ajusta el padding a la derecha si es necesario
                }
                
                // Contenido de la cuadrícula
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
                    .padding(.horizontal, 20) // Ajustar padding horizontal
                    .padding(.bottom, 50) // Ajustar padding inferior para mover los recuadros hacia arriba
                }
            }
            .background(Color(red: 248/255, green: 247/255, blue: 243/255))
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
                        self.items = Array(vm.items.prefix(2))
                    } catch {
                        print("Error fetching user ID or items: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
                appState.userID = ""
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
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 186, height: 212)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 233/255, green: 233/255, blue: 233/255), lineWidth: 1) // Color del borde
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
