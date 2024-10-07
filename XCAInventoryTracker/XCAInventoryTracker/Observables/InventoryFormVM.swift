//
//  InventoryFormVM.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import QuickLookThumbnailing
import Firebase

class InventoryFormViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let formType: FormType
    let id: String
    @Published var name = ""
    @Published var quantity = 0
    @StateObject private var appState = AppState()
    @Published var usdzURL: URL?
    @Published var thumbnailURL: URL?
    
    @Published var loadingState = LoadingType.none
    @Published var error: String?
    
    @Published var uploadProgress: UploadProgress?
    @Published var showUSDZSource = false
    @Published var selectedUSDZSource: USDZSourceType?
 
    
    let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()
    
    var navigationTitle: String {
        switch formType {
        case .add:
            return "Add Item"
        case .edit:
            return "Edit Item"
        }
    }
  

    init(formType: FormType = .add) {
        self.formType = formType
      
        switch formType {
        case .add:
            id = UUID().uuidString
        case .edit(let item):
            
            id = item.id
            name = item.name
            quantity = item.quantity
      
            if let usdzURL = item.usdzURL {
                self.usdzURL = usdzURL
            }
            if let thumbnailURL = item.thumbnailURL {
                self.thumbnailURL = thumbnailURL
            }
        }
    }
    enum FirebaseError: Error {
        case noUserFound
    }
  

    func save(vl: InventoryListViewModel, appState: AppState, token: String, userID: String) async throws {
        loadingState = .savingItem

        defer { loadingState = .none }

        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUserFound
        }

        var item: InventoryItem
        // Define la URL de tu backend API para guardar el item
     
        switch formType {
        case .add:
            item = .init(id: id, name: name, quantity: quantity, userId: userId) // Incluir userId
            print(self.thumbnailURL,self.usdzURL)
            item.usdzLink = usdzURL?.absoluteString
            item.thumbnailLink = thumbnailURL?.absoluteString
            let urlString = "https://scanner3d-backend.vercel.app/api/items"
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Añadir el token en el encabezado
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Especificar que el contenido es JSON
            // Codifica el objeto item a JSON
            do {
                let jsonData = try JSONEncoder().encode(item)
                request.httpBody = jsonData // Establece el cuerpo de la solicitud
            } catch {
                self.error = error.localizedDescription
                throw error
            }

            // Realiza la solicitud de red
            let (data, response) = try await URLSession.shared.data(for: request)

            // Verifica que la respuesta sea exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 201 else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save item"])
            }
        case .edit(let inventoryItem):
            item = inventoryItem
            item.name = name
            item.quantity = quantity
            item.userId = userId // Actualizar userId
            item.usdzLink = usdzURL?.absoluteString
            item.thumbnailLink = thumbnailURL?.absoluteString
            let urlString = "https://scanner3d-backend.vercel.app/api/items/\(item.id)"
            print(urlString)
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Añadir el token en el encabezado
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Especificar que el contenido es JSON
            // Codifica el objeto item a JSON
            do {
           
                let jsonData = try JSONEncoder().encode(item)
                request.httpBody = jsonData // Establece el cuerpo de la solicitud
            } catch {
                self.error = error.localizedDescription
                throw error
            }

            print(request.httpBody)
            // Realiza la solicitud de red
            let (data, response) = try await URLSession.shared.data(for: request)

            // Verifica que la respuesta sea exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print(response,data)
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save item"])
            }
        }
        try await vl.fetchItems(appState: appState, userId: userId, token: token)
    

   
        

     
    }

    @MainActor
    func deleteUSDZ() async {
//        let storageRef = Storage.storage().reference()
//        let usdzRef = storageRef.child("\(id).usdz")
//        let thumbnailRef = storageRef.child("\(id).jpg")
//        
//        loadingState = .deleting(.usdzWithThumbnail)
//        defer { loadingState = .none }
        
        do {
//            try await usdzRef.delete()
//            try? await thumbnailRef.delete()
            self.usdzURL = nil
            self.thumbnailURL = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteItem(vl: InventoryListViewModel,appState: AppState, token: String, userID: String) async throws {
        loadingState = .deleting(.item)
        do {
            let urlString = "https://scanner3d-backend.vercel.app/api/items/\(id)"
            print(urlString)
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Añadir el token en el encabezado
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Especificar que el contenido es JSON
            // Codifica el objeto item a JSON
    

            print(request.httpBody)
            // Realiza la solicitud de red
            let (data, response) = try await URLSession.shared.data(for: request)

            // Verifica que la respuesta sea exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print(response,data)
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save item"])
            }
            try await vl.fetchItems(appState: appState, userId: userID, token: token)
        } catch {
            loadingState = .none
            throw error
        }
    }
    
    @MainActor
    func uploadUSDZ(fileURL: URL, isSecurityScopedResource: Bool = false) async {
        if isSecurityScopedResource, !fileURL.startAccessingSecurityScopedResource() {
            return
        }
      
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if isSecurityScopedResource {
            fileURL.stopAccessingSecurityScopedResource()
        }
        uploadProgress = .init(fractionCompleted: 0, totalUnitCount: 0, completedUnitCount: 0)
        loadingState = .uploading(.usdz)
        
        defer { loadingState = .none }
        do {
            /// Upload USDZ to Firebase Storage
            let storageRef = Storage.storage().reference()
            let usdzRef = storageRef.child("\(id).usdz")
            
            _ = try await usdzRef.putDataAsync(data, metadata: .init(dictionary: ["contentType": "model/vnd.usd+zip"])) { [weak self] progress in
                guard let self, let progress else { return }
                self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
            }
            let downloadURL = try await usdzRef.downloadURL()
            
            /// Generate Thumbnail
            let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileCacheURL = cacheDirURL.appending(path: "temp_\(id).usdz")
            try? data.write(to: fileCacheURL)
            
            let thumbnailRequest = QLThumbnailGenerator.Request(fileAt: fileCacheURL, size: .init(width: 300, height: 300), scale: UIScreen.main.scale, representationTypes: .all)
            
            if let thumbnail = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: thumbnailRequest),
               let jpgData = thumbnail.uiImage.jpegData(compressionQuality: 0.5) {
                loadingState = .uploading(.thumbnail)
                let thumbnailRef = storageRef.child("\(id).jpg")
                _ = try? await thumbnailRef.putDataAsync(jpgData, metadata: .init(dictionary: ["contentType": "image/jpeg"]), onProgress: { [weak self] progress in
                    guard let self, let progress else { return }
                    self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
                })
                
                if let thumbnailURL = try? await thumbnailRef.downloadURL() {
                    self.thumbnailURL = thumbnailURL
                }
            }
            print(downloadURL)
            self.usdzURL = downloadURL
        } catch {
            self.error = error.localizedDescription
        }
    }
    
}

enum FormType: Identifiable {
    
    case add
    case edit(InventoryItem)
    
    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let inventoryItem):
            return "edit-\(inventoryItem.id)"
        }
    }
    
}

enum LoadingType: Equatable {
    
    case none
    case savingItem
    case uploading(UploadType)
    case deleting(DeleteType)
    
}

enum USDZSourceType {
    case fileImporter, objectCapture
}

enum UploadType: Equatable {
    case usdz, thumbnail
}

enum DeleteType {
    case usdzWithThumbnail, item
}

struct UploadProgress {
    var fractionCompleted: Double
    var totalUnitCount: Int64
    var completedUnitCount: Int64
}


