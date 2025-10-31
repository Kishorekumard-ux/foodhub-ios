import SwiftUI

struct LoginView: View {
    @State private var phone = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @State private var navigateToAdmin = false
    @State private var isRegisterActive = false

    @State private var userName = ""
    @State private var userPhone = ""

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("username") var storedUsername = ""
    @AppStorage("phoneNumber") var storedPhone = ""
    @AppStorage("userRole") var storedRole = ""

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

                    Text("Deliver Favourite Food")
                        .font(.headline)

                    VStack(spacing: 15) {
                        TextField("Phone number", text: $phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 12)
                            }
                        }

                        Button(action: {
                            login()
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            } else {
                                Text("Login")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isLoading)

                        Text("OR")
                            .foregroundColor(.red)

                        HStack {
                            Text("Don't have an account?")
                            Button(action: {
                                isRegisterActive = true
                            }) {
                                Text("REGISTER")
                                    .foregroundColor(.red)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Login")
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(userName: userName, phoneNumber: userPhone)
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
            }
            .navigationDestination(isPresented: $navigateToAdmin) {
                AdminPage(adminName: userName, adminPhoneNumber: userPhone)
            }
            .navigationDestination(isPresented: $isRegisterActive) {
                SignUpView()
            }
        }
    }

    func login() {
        guard !phone.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in both fields"
            showAlert = true
            return
        }

        isLoading = true

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/login_page.php") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "phone=\(phone)&password=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
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
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = responseJSON["status"] as? String, status == "success",
                       let userData = responseJSON["data"] as? [String: Any] {

                        let name = userData["name"] as? String ?? ""
                        let phone = userData["phone"] as? String ?? ""
                        let role = userData["role"] as? String ?? "user"

                        DispatchQueue.main.async {
                            self.userName = name
                            self.userPhone = phone

                            storedUsername = name
                            storedPhone = phone
                            storedRole = role
                            isLoggedIn = true

                            if role == "admin" {
                                navigateToAdmin = true
                            } else {
                                navigateToHome = true
                            }
                        }
                    } else {
                        let message = responseJSON["message"] as? String ?? "Login failed"
                        DispatchQueue.main.async {
                            alertMessage = message
                            showAlert = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Invalid response from server"
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
        .environmentObject(ShoppingCartModel())
        .environmentObject(FavoriteModel())
}
