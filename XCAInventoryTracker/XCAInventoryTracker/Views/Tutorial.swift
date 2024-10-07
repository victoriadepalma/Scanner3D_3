//
//  Tutorial.swift
//  XCAInventoryTracker
//
//  Created by Diana Silva De Ornelas on 6/10/24.
//

import SwiftUI

struct Tutorial: View {
    let images = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"] // Nombres de las imágenes en tus assets
    @State private var currentIndex = 0

    var body: some View {
          GeometryReader { geometry in
              ZStack(alignment: .bottom) {
                  // Vista de las imágenes que ocupa todo el largo y ancho
                  TabView(selection: $currentIndex) {
                      ForEach(0..<images.count, id: \.self) { index in
                          Image(images[index])
                              .resizable()
                              .aspectRatio(contentMode: .fit) // Ajusta la imagen sin cortar
                              .frame(width: geometry.size.width, height: geometry.size.height)
                              .clipped() // Evita que la imagen se salga del marco si es necesario
                              .tag(index)
                      }
                  }
                  .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Oculta los puntos automáticos
                  .ignoresSafeArea(edges: .vertical) // Ignora las áreas seguras solo en los bordes verticales

                  // Puntos de paginación personalizados
                  HStack {
                      ForEach(0..<images.count, id: \.self) { index in
                          Circle()
                              .fill(index == currentIndex ? Color(red: 239/255, green: 199/255, blue: 177/255): Color.gray)
                              .frame(width: 6, height: 6) // Puntos más pequeños
                              .padding(.horizontal, 2)
                      }
                  }
                  .padding(.bottom, 20) // Los puntos estarán justo sobre el borde inferior
              }
              .frame(width: geometry.size.width, height: geometry.size.height) // Asegura que todo ocupe el espacio completo
          }
          .ignoresSafeArea(edges: .vertical) // Solo ignoramos las áreas seguras verticales
      }
  }

