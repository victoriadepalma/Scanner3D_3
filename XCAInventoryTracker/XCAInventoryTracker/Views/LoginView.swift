////
//  LoginView.swift
//  Login
//
//  Created by Victoria De Palma and Diana Silva
//


import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    @AppStorage("token") var token: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showErrorModal = false
    @State private var errorMessage: String = ""
    
    private func isValidPassword(_ password: String) -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return passwordRegex.evaluate(with: password)
    }
    
    var body: some View {
        ZStack {
            Color(red: 248/255, green: 247/255, blue: 243/255).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Log In")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(red: 209/255, green: 169/255, blue: 147/255))
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                Spacer()
                
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
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
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
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                )
                .padding()
                
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "signup"
                    }
                }) {
                    Text("Don't have an account? Signup")
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
                Spacer()
                
                Button {
                                    if email.isEmpty || password.isEmpty {
                                        showErrorModal = true
                                        errorMessage = "Please fill in all the required fields."
                                    } else {
                                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                            if let error = error {
                                                showErrorModal = true
                                                errorMessage = "Incorrect email or password"
                                                return
                                            }
                                            
                                            if let authResult = authResult {
                                                let userId = authResult.user.uid
                                                
                                                // Get the ID token asynchronously
                                                authResult.user.getIDToken { idToken, error in
                                                    if let error = error {
                                                        showErrorModal = true
                                                        errorMessage = "Failed to retrieve ID token"
                                                        return
                                                    }
                                                    
                                                    if let idToken = idToken {
                                                        print("User ID: \(userId)")
                                                        print("ID Token: \(idToken)")
                                                        
                                                        withAnimation {
                                                            userID = userId
                                                            token = idToken
                                                        }
                                                        
                                                        // Here you can also store the idToken if needed
                                                        // e.g., UserDefaults.standard.set(idToken, forKey: "idToken")
                                                    }
                                                }
                                            }
                                        }

                                    }
                                } label: {
                                    Text("Sign In")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(red: 239/255, green: 199/255, blue: 177/255))
                                        )
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .alert(isPresented: $showErrorModal) {
                            Alert(
                                title: Text("Error"),
                                message: Text(errorMessage),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
