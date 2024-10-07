//
//  InventoryFormView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import SwiftUI
import SafariServices
import UniformTypeIdentifiers
import USDZScanner
import CoreImage.CIFilterBuiltins
import PhotosUI
import LinkPresentation

struct InventoryFormView: View {
    @StateObject var vl = InventoryListViewModel()
    @StateObject var vm = InventoryFormViewModel()
    @AppStorage("uid") var userID: String = ""
    @AppStorage("token") var token: String = ""
    @StateObject private var appState = AppState()
    @Environment(\.dismiss) var dismiss
    @State private var qrCodeImage: IdentifiableImage?
    @State private var showShareSheet = false

    var body: some View {
        Form {
            List {
                inputSection
                arSection

                if case .deleting(let type) = vm.loadingState {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Deleting \(type == .usdzWithThumbnail ? "USDZ file" : "Item")")
                                .foregroundStyle(.red)
                        }
                        Spacer()
                    }
                }

                if case .edit = vm.formType {
                    Button("Delete", role: .destructive) {
                        Task {
                            do {
                                try await vm.deleteItem(vl:vl,appState:appState,token:token,userID:userID)
                                dismiss()
                            } catch {
                                vm.error = error.localizedDescription
                            }
                        }
                    }
                    .font(.custom("SFProRounded-Regular", size: 17))
                }
            }
        }
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.custom("SFProRounded-Bold", size: 17))
                .foregroundColor(Color(red: 213/255, green: 90/255, blue: 90/255))
                .disabled(vm.loadingState != .none)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                                            do {
                                                try await vm.save(vl:vl,appState:appState,token:token,userID:userID) // Cambiado para usar 'Task'
                                              
                                                dismiss()
                                            } catch {
                                                print("Error al guardar: \(error.localizedDescription)") // Manejo de errores
                                            }
                                        }
                }
                .font(.custom("SFProRounded-Bold", size: 17))
                .foregroundColor(.black)
                .disabled(vm.loadingState != .none || vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog("Add USDZ", isPresented: $vm.showUSDZSource, titleVisibility: .visible, actions: {
            Button("Select file") {
                vm.selectedUSDZSource = .fileImporter
            }

            Button("Object Capture") {
                vm.selectedUSDZSource = .objectCapture
            }
        })
        .sheet(isPresented: .init(get: {
            vm.selectedUSDZSource == .objectCapture
        }, set: { _ in
            vm.selectedUSDZSource = nil
        }), content: {
            USDZScanner { url in
                Task { await vm.uploadUSDZ(fileURL: url) }
                    vm.selectedUSDZSource = nil
            }
        })
        .fileImporter(isPresented: .init(get: { vm.selectedUSDZSource == .fileImporter }, set: { _ in
            vm.selectedUSDZSource = nil
        }), allowedContentTypes: [UTType.usdz], onCompletion: { result in
            switch result {
            case .success(let url):
                Task { await vm.uploadUSDZ(fileURL: url, isSecurityScopedResource: true) }
            case .failure(let failure):
                vm.error = failure.localizedDescription
            }
        })
        .alert(isPresented: .init(get: { vm.error != nil}, set: { _ in vm.error = nil }), error: "An error has occured", actions: { _ in
        }, message: { _ in
            Text(vm.error ?? "")
        })
        .navigationTitle(vm.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let image = qrCodeImage {
                ShareSheet(items: [image.url])
            }
        }
    }

    var inputSection: some View {
        Section {
            TextField("Name", text: $vm.name)
                .font(.custom("SFProRounded-Regular", size: 17))
        }
        .disabled(vm.loadingState != .none)
    }

    var arSection: some View {
        Section(header: Text("AR Model")
            .font(.custom("SFProRounded-Regular", size: 14))
        ) {
            if let thumbnailURL = vm.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .failure:
                        Text("Failed to fetch thumbnail")
                    default:
                        ProgressView()
                    }
                }
                .onTapGesture {
                    guard let usdzURL = vm.usdzURL else { return }
                    viewAR(url: usdzURL)
                }
            }

            if let usdzURL = vm.usdzURL {
                Button {
                    viewAR(url: usdzURL)
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text("View")
                            .font(.custom("SFProRounded-Regular", size: 17))
                    }
                }

                Button("Generate QR Code") {
                    generateQRCode(for: usdzURL)
                }
                .font(.custom("SFProRounded-Regular", size: 17))

                Button("Delete USDZ", role: .destructive) {
                    Task { await vm.deleteUSDZ() }
                }
                .font(.custom("SFProRounded-Regular", size: 17))

            } else {
                Button {
                    vm.showUSDZSource = true
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text("Add USDZ")
                            .font(.custom("SFProRounded-Regular", size: 17))
                    }
                }
            }

            if let progress = vm.uploadProgress,
               case let .uploading(type) = vm.loadingState,
               progress.totalUnitCount > 0 {
                VStack {
                    ProgressView(value: progress.fractionCompleted) {
                        Text("Uploading \(type == .usdz ? "USDZ" : "Thumbnail") file \(Int(progress.fractionCompleted * 100))%")
                    }

                    Text("\(vm.byteCountFormatter.string(fromByteCount: progress.completedUnitCount)) / \(vm.byteCountFormatter.string(fromByteCount: progress.totalUnitCount))")
                }
            }
        }
        .disabled(vm.loadingState != .none)
    }

    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }

    func generateQRCode(for url: URL) {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        
        let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale up the QR code image for higher resolution
        
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                
                // Resize the image to a smaller size to improve sharpness
                let scaledImage = resizeImage(image: uiImage, targetSize: CGSize(width: 300, height: 300))
                
                // Convert UIImage to PNG data
                if let pngData = scaledImage.pngData() {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("qrCode.png")
                    do {
                        // Save PNG data to a temporary file
                        try pngData.write(to: tempURL)
                        self.qrCodeImage = IdentifiableImage(url: tempURL)
                        self.showShareSheet = true
                    } catch {
                        print("Failed to save QR code image to temporary file: \(error)")
                    }
                }
            }
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let activities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
