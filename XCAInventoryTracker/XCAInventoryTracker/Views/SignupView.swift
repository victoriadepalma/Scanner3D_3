


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
    @AppStorage("token") var token: String = ""
    @Binding var currentShowingView: String
    @State private var showAlert = false
    @State private var passwordErrorText = ""
    
    private func registerUserToBackend(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Prepare the URL for your backend endpoint
        guard let url = URL(string: "https://scanner3d-backend.vercel.app/api/users/register") else {
            print("Invalid URL")
            return
        }

        // Prepare the JSON data
        let userData: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "password": password
        ]

        // Convert userData dictionary to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            print("Failed to encode JSON data")
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors
            if let error = error {
                print("Error making request to backend: \(error)")
                completion(.failure(error))
                return
            }

            // Check the response status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    // Parse the response data
                    if let data = data {
                        do {
                            // Convert the JSON data to a dictionary
                            if let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("User registered successfully: \(responseData)")
                                // Return the response data
                                completion(.success(responseData))
                            } else {
                                print("Failed to parse response data")
                                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response data"])))
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                            completion(.failure(error))
                        }
                    }
                } else {
                    print("Failed to register user. Status code: \(httpResponse)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to register user"])))
                }
            }
        }.resume()
    }

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
                        .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
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
                .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                )
                .padding()
                
                HStack {
                    Image(systemName: "person")
                    TextField("Last Name", text: $lastName)
                }
                .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
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
                .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                    
                )
                
                .padding()
                
                
                HStack {
                                Image(systemName: "lock")
                                SecureField("Password", text: $password)
                                
                                Spacer()
                                
                                if(password.count != 0) {
                                    if !isValidPassword(password) {
                                        Image(systemName: "xmark")
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    } else {
                                        Image(systemName: "checkmark")
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color(red: 239/255, green: 199/255, blue: 177/255))
                            )
                            .padding()
                            
                            if !isValidPassword(password) {
                                Text("Password must be at least 6 characters long, contain 1 uppercase letter, and 1 special character.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16) // Añade 16 puntos de padding a los lados
                                    .padding(.bottom, 8)
                            }
              
                    
                
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
                        registerUserToBackend { result in
                                   switch result {
                                   case .success(let userData):
                                       print("entre1")
                                       Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                           print("entre2",authResult, error)
                                           if let error = error {
                                               print(error)
                                               showAlert = true
                                               return
                                           }
                                           print("entre3")
                                           if let authResult = authResult {
                                               let userId = authResult.user.uid
                                               print("entre4")
                                               // Get the ID token asynchronously
                                               authResult.user.getIDToken { idToken, error in
                                                   print("entre5",idToken,error)
                                                   if let error = error {
                                        
                                                       showAlert = true
                                                       return
                                                   }
                                                   print("entre6")
                                                   
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

                                   case .failure(let error):
                                       // Handle failure, e.g., show an alert
                                       print("Failed to register user: \(error.localizedDescription)")
                                       DispatchQueue.main.async {
                                           // Show an error message to the user on the main thread
                                           showAlert = true
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
                                .fill(Color(red: 239/255, green: 199/255, blue: 177/255))
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
