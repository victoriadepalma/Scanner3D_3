//
//  EditProfileView.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var passwordError: String = ""
    
    let userId: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Password")) {
                    SecureField("New Password", text: $password)
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: {
                    let passwordValidationResult = viewModel.validatePassword(password)
                    if passwordValidationResult.isValid {
                        viewModel.updateProfile(
                            userId: userId,
                            firstName: firstName,
                            lastName: lastName,
                            password: password
                        ) { success in
                            if success {
                                dismiss()
                            }
                        }
                    } else {
                        passwordError = passwordValidationResult.errorMessage
                    }
                }) {
                    Text("Save Changes")
                }
            }
            .navigationBarTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadUserData(userId: userId) { user in
                    firstName = user?.firstName ?? ""
                    lastName = user?.lastName ?? ""
                }
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userId: "123456789")
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
                      firstName: userData["firstName"] as? String,
                      lastName: userData["lastName"] as? String
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
        
        // Minimum 6 characters
        if password.count < 6 {
            isValid = false
            errorMessage += "Password must be at least 6 characters long. "
        }
        
        // 1 uppercase character
        if !password.contains(where: { $0.isUppercase }) {
            isValid = false
            errorMessage += "Password must contain at least one uppercase character. "
        }
        
        // 1 special character
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
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        let userRef = db.collection("users").document(userId)
        
        // Update user data in Firestore
        userRef.updateData([
            "firstName": firstName,
            "lastName": lastName
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

struct User {
    let firstName: String?
    let lastName: String?
}
