
//  SignupView.swift
//  Login
//
//  Created by Victoria De Palma and Diana Silva
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @AppStorage("uid") var userID: String = ""
    @Binding var currentShowingView: String
    @State private var showAlert = false
    
    
    
    
    private func isValidPassword(_ password: String) -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        return passwordRegex.evaluate(with: password)
    }
    
    private func areAllFieldsFilled() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Sign up")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Image(systemName: "person")
                    TextField("First Name", text: $firstName)
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                )
                .padding()
                
                HStack {
                    Image(systemName: "person")
                    TextField("Last Name", text: $lastName)
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                )
                .padding()
                
                HStack {
                    Image(systemName: "mail")
                    TextField("Email", text: $email)
                    
                    Spacer()
                    
                    
                    if(email.count != 0) {
                        
                        Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(email.isValidEmail() ? .green : .red)
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                    
                )
                
                .padding()
                
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                    
                    Spacer()
                    
                    if(password.count != 0) {
                        
                        Image(systemName: isValidPassword(password) ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(isValidPassword(password) ? .green : .red)
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                    
                )
                .padding()
                
                
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "login"
                    }
                }) {
                    Text("Already have an account? Login")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Spacer()
                
                
                Button {
                    // Check if all fields are filled
                    if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty {
                        // Display an alert if any field is empty
                        showAlert = true
                    } else {
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            if let authResult = authResult {
                                print(authResult.user.uid)
                                userID = authResult.user.uid
                                
                                // Save the first name and last name to Firestore
                                let userData: [String: Any] = [
                                    "firstName": firstName,
                                    "lastName": lastName,
                                    "email": email
                                ]
                                
                                let db = Firestore.firestore()
                                db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                    if let error = error {
                                        print("Error saving user data: \(error)")
                                    } else {
                                        print("User data saved successfully")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Text("Create New Account")
                        .foregroundColor(.black)
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .padding(.horizontal)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Missing Fields"),
                        message: Text("Please fill in all the required fields."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}
