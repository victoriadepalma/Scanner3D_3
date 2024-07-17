//
//  SignupViewModel.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import SwiftUI
import FirebaseAuth

class SignupViewModel: ObservableObject {
    @Published var isSignedUp = false
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                return
            }
            
            if let authResult = authResult {
                print("Signed up user with UID: \(authResult.user.uid)")
                self.isSignedUp = true
            }
        }
    }
}
