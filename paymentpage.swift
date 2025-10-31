import SwiftUI

struct PaymentPage: View {
    let totalPrice: Int
    let totalItems: Int
    let cartItems: [CartItem]
    let address: String
    let orderType: String
    let deliveryDate: Date?
    let deliveryTime: Date?
    let userName: String
    let phoneNumber: String
    let description: String

    @State private var selectedPaymentMethod = "Google Pay"
    @State private var transactionId = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    var deliveryCharges: Double {
        totalPrice > 100 ? 0 : 20
    }

    var finalAmount: Double {
        Double(totalPrice) + deliveryCharges
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order Summary")
                        .font(.headline)

                    ForEach(cartItems) { item in
                        VStack {
                            HStack {
                                Text("\(item.name) (\(item.quantity))")
                                Spacer()
                                Text("₹\(Int(item.price))")
                            }
                            Divider()
                        }
                    }

                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(totalItems)")
                    }

                    HStack {
                        Text("Delivery Charges")
                        Spacer()
                        Text(deliveryCharges > 0 ? "₹20" : "Free")
                    }

                    HStack {
                        Text("Total Amount").bold()
                        Spacer()
                        Text("₹\(Int(finalAmount))").bold()
                    }

                    Text("Delivery Details").font(.headline)
                    Text("Address: \(address)")
                    Text("Order Type: \(orderType)")
                    if let date = deliveryDate {
                        Text("Delivery Date: \(date, formatter: dateFormatter)")
                    }
                    if let time = deliveryTime {
                        Text("Delivery Time: \(time, formatter: timeFormatter)")
                    }

                    Text("Payment Method").font(.headline)
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        Text("Google Pay").tag("Google Pay")
                        Text("Cash on Delivery").tag("Cash on Delivery")
                    }
                    .pickerStyle(.segmented)

                    if selectedPaymentMethod == "Google Pay" {
                        Text("While paying, please mention your name.")
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Image("gpay")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .scaledToFit()
                            .centered()

                        TextField("Enter Transaction ID", text: $transactionId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top, 10)
                    }

                    Button(action: {
                        storePaymentDetails()
                    }) {
                        Text("Confirm Payment")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                (selectedPaymentMethod == "Google Pay" && transactionId.isEmpty)
                                ? Color.gray
                                : Color.black
                            )
                            .cornerRadius(8)
                    }
                    .disabled(selectedPaymentMethod == "Google Pay" && transactionId.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Payment")
            .navigationBarBackButtonHidden(true)

            // ✅ Alert and Home Navigation
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Info"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("✅ Order placed") {
                            navigateToHome = true
                        }
                    }
                )
            }

            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    func storePaymentDetails() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/insert_order.php") else {
            self.alertMessage = "Invalid server URL."
            self.showingAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let cartItemsData = cartItems.map {
            ["name": $0.name, "quantity": $0.quantity, "price": $0.price]
        }

        let cartItemsJSONString: String
        do {
            let data = try JSONSerialization.data(withJSONObject: cartItemsData, options: [])
            cartItemsJSONString = String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            self.alertMessage = "Failed to encode cart items."
            self.showingAlert = true
            return
        }

        let params: [String: String] = [
            "userName": userName,
            "phoneNumber": phoneNumber,
            "address": address,
            "description": description,
            "orderType": orderType,
            "deliveryDate": deliveryDate.map { dateFormatter.string(from: $0) } ?? "",
            "deliveryTime": deliveryTime.map { timeFormatter.string(from: $0) } ?? "",
            "totalItems": "\(totalItems)",
            "totalPrice": "\(totalPrice)",
            "paymentMethod": selectedPaymentMethod,
            "transactionId": transactionId,
            "cartItems": cartItemsJSONString
        ]

        let bodyString = params.map {
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = "❌ Network error: \(error.localizedDescription)"
                } else if let data = data {
                    print("📦 Server Response:\n", String(data: data, encoding: .utf8) ?? "No response")

                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            self.alertMessage = "✅ Order placed successfully! Tap OK to continue."
                        } else if let errorMsg = json["error"] as? String {
                            self.alertMessage = "❌ Server error: \(errorMsg)"
                        } else {
                            self.alertMessage = "⚠️ Unknown server response."
                        }
                    } else {
                        self.alertMessage = "⚠️ Invalid response from server."
                    }
                } else {
                    self.alertMessage = "⚠️ No data received from server."
                }
                self.showingAlert = true
            }
        }.resume()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter
}()

// Helper to center view horizontally
extension View {
    func centered() -> some View {
        HStack { Spacer(); self; Spacer() }
    }
}

// MARK: - Preview
#Preview {
    PaymentPage(
        totalPrice: 120,
        totalItems: 3,
        cartItems: [
            CartItem(
                id: 1,
                name: "Pizza",
                description: "Cheesy and hot pizza",
                price: 60,
                imageUrl: "https://example.com/pizza.jpg",
                quantity: 2
            )
        ],
        address: "123 Street, City",
        orderType: "Regular",
        deliveryDate: Date(),
        deliveryTime: Date(),
        userName: "Kishore Kumar",
        phoneNumber: "9876543210",
        description: "Please deliver hot."
    )
}
