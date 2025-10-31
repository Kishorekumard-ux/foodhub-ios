import SwiftUI

struct AdminAccountView: View {
    @State private var adminName: String
    @State private var adminPhone: String
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(adminName: String, adminPhone: String) {
        _adminName = State(initialValue: adminName)
        _adminPhone = State(initialValue: adminPhone)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("user")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                    TextField("Admin Name", text: $adminName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("Phone Number", text: $adminPhone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    } else {
                        Button(action: {
                            updateAdminDetails()
                        }) {
                            Text("Update Admin Details")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Admin Account")
        }
    }

    func updateAdminDetails() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/update_admin_details.php") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            return
        }

        isLoading = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(adminName)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"phone\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(adminPhone)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

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
                if let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        alertMessage = responseJSON["message"] as? String ?? "Unknown response"
                        showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Failed to parse response"
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    AdminAccountView(adminName: "Admin", adminPhone: "1234567890")
}
