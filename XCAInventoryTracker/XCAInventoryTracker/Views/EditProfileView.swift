//
//  EditProfileView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma on 6/19/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    let userId: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                }
                
                Section(header: Text("Password")) {
                    SecureField("New Password", text: $password)
                }
                
                Button(action: {
                    viewModel.updateProfile(
                        userId: userId,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        password: password
                    ) { success in
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    Text("Save Changes")
                }
            }
            .navigationBarTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

class EditProfileViewModel: ObservableObject {
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        // Update user data in Firestore
        userRef.updateData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
                completion(false)
            } else {
                // Update user data in Firebase Authentication
                if !password.isEmpty {
                    Auth.auth().currentUser?.updatePassword(to: password) { error in
                        if let error = error {
                            print("Error updating user password: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
}

