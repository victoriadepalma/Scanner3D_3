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
        NavigationView {
            ZStack {
                Color(red: 239/255, green: 199/255, blue: 177/255) // Color EFC7B1
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                    
                        Image("naraja-sofa-png")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(geometry.size.width * 1.3, 600), // Ajusta el tamaño máximo
                                height: min(geometry.size.width * 1.3, 600) // Ajusta el tamaño máximo
                            )
                            .frame(maxWidth: .infinity)
                        
         
                        HStack {
                       
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Scan,")
                                    .font(.custom("SFProRounded-Bold", size: min(geometry.size.width, geometry.size.height) * 0.08))
                                    .foregroundColor(.white)
                                Text("Visualize and")
                                    .font(.custom("SFProRounded-Bold", size: min(geometry.size.width, geometry.size.height) * 0.08).bold())
                                    .foregroundColor(.white)
                                Text("Export in one click")
                                    .font(.custom("SFProRounded-Bold", size: min(geometry.size.width, geometry.size.height) * 0.08).bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            
                            NavigationLink(destination: InventoryListView()) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .overlay(
                                        Image("flecha")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1) 
                                    )
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.bottom, 20)
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
