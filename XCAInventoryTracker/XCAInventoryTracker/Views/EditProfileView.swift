//
//  EditProfileView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma on 6/19/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var passwordError: String = ""
    @State private var profileImage: Image? // To display the selected image
    @State private var imageData: Data? // To hold the image data
    @State private var showingImagePicker = false
    @State private var profileImageURL: String? // To store the URL of the profile image
    @State private var email: String = "" // To hold the email
    
    let userId: String
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: 0) {
                    // Header Rectangle
                    Rectangle()
                        .fill(Color(hex: "#EFC7B1"))
                        .frame(height: geometry.size.height * 0.2) // 20% of screen height
                        .edgesIgnoringSafeArea(.top)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Spacer().frame(height: geometry.size.height * 0.1) // Adjust to move image down
                                        
                                        if let profileImage = profileImage {
                                            profileImage
                                                .resizable()
                                                .aspectRatio(contentMode: .fill) // Ajuste de aspecto
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35) // Tamaño del círculo
                                                .clipShape(Circle()) // Recorte en forma de círculo
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Borde opcional
                                        } else if let urlString = profileImageURL, let url = URL(string: urlString) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill) // Ajuste de aspecto
                                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35) // Tamaño del círculo
                                                    .clipShape(Circle()) // Recorte en forma de círculo
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Borde opcional
                                            } placeholder: {
                                                Image("profilepic") // Imagen predeterminada
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill) // Ajuste de aspecto
                                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35) // Tamaño del círculo
                                                    .clipShape(Circle()) // Recorte en forma de círculo
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Borde opcional
                                            }
                                        } else {
                                            Image("profilepic") // Imagen predeterminada
                                                .resizable()
                                                .aspectRatio(contentMode: .fill) // Ajuste de aspecto
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35) // Tamaño del círculo
                                                .clipShape(Circle()) // Recorte en forma de círculo
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Borde opcional
                                        }

                                        
                                        // Button container
                                        VStack {
                                            Rectangle()
                                                .fill(Color(hex: "#EFC7B1"))
                                                .frame(width: 43, height: 42)
                                                .cornerRadius(10)
                                                .overlay(
                                                    Button(action: {
                                                        showingImagePicker.toggle()
                                                        print("Botón presionado: \(showingImagePicker)")
                                                    }) {
                                                        Image("lapiz") // Button image from assets
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 25, height: 26) // Set dimensions
                                                            .padding(5)
                                                    }
                                                    .buttonStyle(PlainButtonStyle()) // Removes default button styling
                                                )
                                                .padding(.top, -30)
                                            
                                            // Display full name
                                            Text("\(firstName) \(lastName)")
                                                .font(.custom("SFProRounded-Bold", size: 32))
                                                .padding(.top, 10)
                                        }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding(.top, geometry.size.height * 0.15) // Adjust to position the profile image
                        )
                    
                    // Scrollable Content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Add Spacer to push fields down
                            Spacer().frame(height: geometry.size.height * 0.09) // Adjust for spacing

                            // Personal Information Section
                            VStack(spacing: 20) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Email")
                                        .font(.custom("SFProRounded-Bold", size: 17))
                                        .padding(.horizontal)

                                    HStack(spacing: 10) {
                                        Image("mail")
                                            .resizable()
                                            .frame(width: 20, height: 20) // Size of the mail icon
                                            .aspectRatio(contentMode: .fit)

                                        Text(email) // Display email as non-editable text
                                            .font(.custom("SFProRounded-Regular", size: 17))
                                            .foregroundColor(Color(hex: "#4B4B4B"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding()
                                    .background(Color(hex: "#F5F5F5"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#E9E9E9"), lineWidth: 1)
                                    )
                                    .frame(height: geometry.size.height * 0.07) // Keep the height of the rectangle relative to screen size
                                    .padding(.horizontal)
                                }
                            


                                
                                // First Name Field
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Name")
                                        .font(.custom("SFProRounded-Bold", size: 17))
                                        .padding(.horizontal)
                                    
                                    TextField("First Name", text: $firstName)
                                        .font(.custom("SFProRounded-Regular", size: 17))
                                        .foregroundColor(Color(hex: "#4B4B4B"))
                                        .padding()
                                        .background(Color(hex: "#F5F5F5"))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "#E9E9E9"), lineWidth: 1)
                                        )
                                        .frame(height: geometry.size.height * 0.07) // Set height relative to screen size
                                        .padding(.horizontal)
                                }
                                
                                // Last Name Field
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Lastname")
                                        .font(.custom("SFProRounded-Bold", size: 17))
                                        .padding(.horizontal)
                                    
                                    TextField("Last Name", text: $lastName)
                                        .font(.custom("SFProRounded-Regular", size: 17))
                                        .foregroundColor(Color(hex: "#4B4B4B"))
                                        .padding()
                                        .background(Color(hex: "#F5F5F5"))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "#E9E9E9"), lineWidth: 1)
                                        )
                                        .frame(height: geometry.size.height * 0.07) // Set height relative to screen size
                                        .padding(.horizontal)
                                }
                            }
                            
                            // Password Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Password")
                                    .font(.custom("SFProRounded-Bold", size: 17))
                                    .padding(.horizontal)
                                
                                SecureField("New Password", text: $password)
                                    .font(.custom("SFProRounded-Regular", size: 17))
                                    .foregroundColor(Color(hex: "#4B4B4B"))
                                    .padding()
                                    .background(Color(hex: "#F5F5F5"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#E9E9E9"), lineWidth: 1)
                                    )
                                    .frame(height: geometry.size.height * 0.07) // Set height relative to screen size
                                    .padding(.horizontal)
                                
                                if !passwordError.isEmpty {
                                    Text(passwordError)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }
                            }
                        
//                                .frame(maxWidth: .infinity)
//                                .padding()
                            
                            // Save Changes Button
                            Button(action: {
                                if password.isEmpty || viewModel.validatePassword(password).isValid {
                                    viewModel.updateProfile(
                                        userId: userId,
                                        firstName: firstName,
                                        lastName: lastName,
                                        password: password.isEmpty ? nil : password, // Pass nil if password is empty
                                        profileImageData: imageData // Pass the image data
                                    ) { success in
                                        if success {
                                            viewModel.loadUserData(userId: userId) { user in
                                                firstName = user?.firstName ?? ""
                                                lastName = user?.lastName ?? ""
                                                profileImageURL = user?.profileImageURL
                                                
                                                if let urlString = user?.profileImageURL, let url = URL(string: urlString) {
                                                    // Load the existing profile image
                                                    DispatchQueue.global().async {
                                                        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                                            DispatchQueue.main.async {
                                                                profileImage = Image(uiImage: uiImage)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            dismiss()
                                        }
                                    }
                                } else {
                                    passwordError = viewModel.validatePassword(password).errorMessage
                                }
                            }) {
                                Text("Save Changes")
                                                .font(.custom("SFProRounded-Bold", size: 15))
                                                .frame(width: geometry.size.width * 0.4, height: 43) // Ancho adaptado a distintos tamaños
                                                .background(Color(hex: "#FE7714"))
                                                .foregroundColor(.black)
                                                .cornerRadius(10)
                                                .padding(.horizontal)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
//                        .padding(.top, -10)
                        
                    }
                    .padding(.top, geometry.size.height * 0.01)
                    .padding(.top, 75)
                    
                    
                    
                }
                .background(Color(hex: "#F8F7F3"))
                .navigationTitle("") // Remove the navigation title
                .navigationBarTitleDisplayMode(.inline) // Set title display mode to inline
                .onAppear {
                    viewModel.loadUserData(userId: userId) { user in
                        firstName = user?.firstName ?? ""
                        lastName = user?.lastName ?? ""
                        email = user?.email ?? "" // Set the email field
                        profileImageURL = user?.profileImageURL
                        
                        if let urlString = user?.profileImageURL, let url = URL(string: urlString) {
                            // Load the existing profile image
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(imageData: $imageData, onImagePicked: { image in
                        profileImage = image
                    })
                }
            }
        }
    }
}


struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        if let userId = Auth.auth().currentUser?.uid {
            EditProfileView(userId: userId)
        } else {
            Text("No user is currently authenticated.")
                .foregroundColor(.red)
        }
    }
}


class EditProfileViewModel: ObservableObject {
    let db = Firestore.firestore()
    
    func loadUserData(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting user data: \(error)")
                completion(nil)
            } else if let userData = snapshot?.data() {
                let user = User(
                    email: userData["email"] as? String, // Load email
                    firstName: userData["firstName"] as? String,
                    lastName: userData["lastName"] as? String,
                    profileImageURL: userData["profileImageURL"] as? String
                )
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    struct PasswordValidationResult {
        let isValid: Bool
        let errorMessage: String
    }
    
    func validatePassword(_ password: String) -> PasswordValidationResult {
        var isValid = true
        var errorMessage = ""
        
        if password.count < 6 {
            isValid = false
            errorMessage += "Password must be at least 6 characters long. "
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            isValid = false
            errorMessage += "Password must contain at least one uppercase character. "
        }
        
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*(),.?\":{}|<>")
        if password.rangeOfCharacter(from: specialCharacterSet) == nil {
            isValid = false
            errorMessage += "Password must contain at least one special character. "
        }
        
        return PasswordValidationResult(isValid: isValid, errorMessage: errorMessage)
    }
    
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        password: String?,
        profileImageData: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        let userRef = db.collection("users").document(userId)
        
        var updates: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]
        
        if let imageData = profileImageData {
            let storage = Storage.storage()
            let storageRef = storage.reference().child("profile_images/\(userId).jpg")
            let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(false)
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting image URL: \(error.localizedDescription)")
                            completion(false)
                        } else if let url = url {
                            updates["profileImageURL"] = url.absoluteString
                            userRef.updateData(updates) { error in
                                if let error = error {
                                    print("Error updating user data: \(error.localizedDescription)")
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            userRef.updateData(updates) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        
        if let password = password {
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                if let error = error {
                    print("Error updating password: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct User {
    let email: String? // Added email property
    let firstName: String?
    let lastName: String?
    let profileImageURL: String?
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
