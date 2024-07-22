//
//  HomeView.swift
//  XCAInventoryTracker
//
//  Created by Diana Silva De Ornelas on 17/7/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var inventoryVM = InventoryListViewModel()
    @State private var appState = AppState()
    
    var body: some View {
        ZStack {
            Color(red: 85/255, green: 79/255, blue: 79/255)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Image("Ikea-Place-2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: geometry.size.height * 0.75)
                        .clipped()
                        .opacity(0.5)
                        .overlay(
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Scan,")
                                    .font(.custom("SFProRounded-Bold", size: 32))
                                    .foregroundColor(.white)
                                Text("Visualize and")
                                    .font(.custom("SFProRounded-Bold", size: 32).bold())
                                    .foregroundColor(.white)
                                Text("Export in one click")
                                    .font(.custom("SFProRounded-Bold", size: 32).bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, -90)
                            .padding(.top, -150)
                        )
                        .frame(height: geometry.size.height * 0.75)
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(height: 464)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.top, -50)
                        .overlay(
                            VStack(alignment: .leading) { // Alineación a la izquierda
                                if inventoryVM.items.isEmpty {
                                    Text("Make your first scan")
                                        .font(.custom("SFProRounded-Bold", size: 24))
                                        .foregroundColor(.black)
                                        .padding(.leading, 20)
                                } else {
                                    HStack(spacing: 20) { // Ajuste del espaciado
                                        ForEach(Array(inventoryVM.items.prefix(2)), id: \.id) { item in
                                            VStack(alignment: .leading) { // Alineación a la izquierda
                                                if let thumbnailURL = item.thumbnailURL {
                                                    AsyncImage(url: thumbnailURL) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 160, height: 200) // Tamaño reducido
                                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                .shadow(color: Color.black.opacity(0.20), radius: 10, x: 0, y: 5)
                                                        default:
                                                            ProgressView()
                                                        }
                                                    }
                                                    .frame(width: 160, height: 200) // Tamaño reducido
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(item.name)
                                                        .font(.custom("SFProRounded-Bold", size: 17))
                                                    Text("Quantity: \(item.quantity)")
                                                        .font(.custom("SFProRounded-Regular", size: 17))
                                                }
                                                .padding(.leading, 10) // Ajusta el padding si es necesario
                                            }
                                        }
                                    }
                                    .padding(20)
                                }
                            }
                        )
                    
                    Text("My Products")
                        .font(.custom("SFProRounded-Bold", size: 32))
                        .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                        .offset(y: -420)
                        .padding(.leading, -160)
                    
                    NavigationLink(destination: InventoryListView()) {
                        Text("View all")
                            .underline()
                            .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                    }
                    .font(.custom("SFProRounded-Bold", size: 17))
                    .foregroundColor(.black)
                    .underline()
                    .offset(y: -449)
                    .padding(.leading, 280)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                print("Family: \(family) Font names: \(names)")
            }
            Task {
                do {
                    guard let currentUser = Auth.auth().currentUser else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user found"])
                    }
                    let userId = currentUser.uid
                    try await inventoryVM.listenToItems(appState: appState, userId: userId)
                } catch {
                    print("Error fetching items: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: HomeView {
        HomeView()
    }
}
