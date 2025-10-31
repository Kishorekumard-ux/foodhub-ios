import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @State private var isLoginActive = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("page")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                    Text("FoodHub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("Deliver Favourite Food")
                        .font(.headline)
                        .foregroundColor(.black)

                    Group {
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        TextField("Phone number", text: $phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        createAccount()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        } else {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)

                    // Navigation to Login Page
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)

                        Button(action: {
                            isLoginActive = true
                        }) {
                            Text("Login")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarBackButtonHidden(true)

            // ✅ Modern navigationDestination
            .navigationDestination(isPresented: $isLoginActive) {
                LoginView()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(userName: name, phoneNumber: phone)
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    func createAccount() {
        guard !name.isEmpty, !phone.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "All fields are required"
            showAlert = true
            return
        }

        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }

        isLoading = true

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/signup.php") else {
            alertMessage = "Invalid URL"
            showAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = "name=\(name)&phone=\(phone)&password=\(password)"
        request.httpBody = bodyData.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "No data received"
                    showAlert = true
                }
                return
            }

            do {
                if let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = responseData["status"] as? String {
                    DispatchQueue.main.async {
                        if status == "success" {
                            alertMessage = "Account created successfully"
                            showAlert = true
                            navigateToHome = true
                        } else {
                            let message = responseData["message"] as? String ?? "Unknown error"
                            alertMessage = message
                            showAlert = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Error parsing response"
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    SignUpView()
}
