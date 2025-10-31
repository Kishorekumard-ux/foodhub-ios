import SwiftUI

struct AccountPage: View {
    let userName: String
    let phoneNumber: String

    @State private var name: String
    @State private var phone: String
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteAlert = false
    @State private var navigateToWelcome = false
    @State private var navigateToLogin = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var favoriteModel: FavoriteModel

    init(userName: String, phoneNumber: String) {
        self.userName = userName
        self.phoneNumber = phoneNumber
        _name = State(initialValue: userName)
        _phone = State(initialValue: phoneNumber)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("user")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)

                    TextField("Phone Number", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                        .foregroundColor(.black)

                    if isLoading {
                        ProgressView()
                    } else {
                        Button(action: updateDetails) {
                            Text("Update Details")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        buildButton("Orders", destination: MyUserOrdersPage(phoneNumber: phoneNumber))
                        
                        buildButton("Coupons", destination: CouponsPage())
                        buildButton("About", destination: AboutPage())
                        buildButton("Help Center", destination: HelpCenterPage())

                        // ✅ Added Delete Account Button here
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Text("Delete Account")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Image("logout")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .navigationDestination(isPresented: $navigateToLogin) {
                                    LoginView()
                                }
                }
                .padding()
            }
            .navigationTitle("Account")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Do you really want to delete your account?"),
                    primaryButton: .destructive(Text("Yes")) {
                        deleteAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $navigateToWelcome) {
                ContentView() // Replace with your actual welcome screen
            }
        }
    }

    private func buildButton<Destination: View>(_ title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
    }

    private func updateDetails() {
        isLoading = true

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/update_user_details.php") else {
            alertMessage = "Invalid URL"
            showingAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["name": name, "phone": phone]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String {
                    if status == "success" {
                        alertMessage = "Details updated successfully"
                    } else {
                        alertMessage = json["message"] as? String ?? "Unknown error"
                    }
                } else {
                    alertMessage = "Failed to update details"
                }
                showingAlert = true
            }
        }.resume()
    }

    private func deleteAccount() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/delete_user.php") else {
            alertMessage = "Invalid URL"
            showingAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "phone=\(phone)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String {
                    if status == "success" {
                        // ✅ Clear stored session (example: UserDefaults)
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        UserDefaults.standard.synchronize()

                        // For extra safety
                        name = ""
                        phone = ""

                        // ✅ Navigate to welcome or login screen
                        navigateToWelcome = true
                    } else {
                        alertMessage = json["message"] as? String ?? "Deletion failed"
                        showingAlert = true
                    }
                } else {
                    alertMessage = "Network error or server not responding"
                    showingAlert = true
                }
            }
        }.resume()
    }

}

struct AccountPage_Previews: PreviewProvider {
    static var previews: some View {
        AccountPage(userName: "John Doe", phoneNumber: "1234567890")
            .environmentObject(FavoriteModel())
    }
}
