import SwiftUI

// MARK: - Order Model
struct Order: Identifiable, Codable {
    let id: String
    let user_name: String
    let phone_number: String // <-- Added phone number
    let address: String
    let cart_items: String
    let total_price: String
    let payment_method: String
    let created_at: String
    let delivery_time: String
    let order_type: String
    var status: String
    let transaction_id: String?
}

// MARK: - Response Models
struct OrderResponse: Codable {
    let success: Bool
    let data: [Order]
    let message: String?
}

struct CancelResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - ViewModel
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        fetchOrders()
    }

    func fetchOrders() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/get_orders.php") else {
            print("Invalid URL")
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"request\"\r\n\r\n".data(using: .utf8)!)
        body.append("fetch_orders\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error occurred."
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self.orders = decodedResponse.data.sorted { $0.created_at > $1.created_at }
                        self.errorMessage = self.orders.isEmpty ? "No orders found." : nil
                    } else {
                        self.errorMessage = decodedResponse.message ?? "Failed to fetch orders."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response."
                }
            }
        }.resume()
    }

    func cancelOrder(order: Order) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/cancel_order.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "orderId=\(order.id)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Cancel error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CancelResponse.self, from: data)
                if decoded.success {
                    DispatchQueue.main.async {
                        if let index = self.orders.firstIndex(where: { $0.id == order.id }) {
                            self.orders[index].status = "Cancelled"
                        }
                    }
                } else {
                    print("Server responded with error:", decoded.message)
                }
            } catch {
                print("Cancel decoding failed: \(error.localizedDescription)")
            }
        }.resume()
    }

    // New: Mark order as delivered using refund_order.php
    func markOrderDelivered(order: Order) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/refund_order.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(order.id)&status=Delivered"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Deliver error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CancelResponse.self, from: data)
                if decoded.success {
                    DispatchQueue.main.async {
                        if let index = self.orders.firstIndex(where: { $0.id == order.id }) {
                            self.orders[index].status = "Delivered"
                        }
                    }
                } else {
                    print("Deliver failed:", decoded.message)
                }
            } catch {
                print("Deliver decode failed:", error.localizedDescription)
            }
        }.resume()
    }

    func refundOrder(order: Order) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/refund_order.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(order.id)&status=Refunded"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Refund error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CancelResponse.self, from: data)
                print("Refund server response:", decoded.success, decoded.message)
                if decoded.success {
                    DispatchQueue.main.async {
                        if let index = self.orders.firstIndex(where: { $0.id == order.id }) {
                            var updatedOrder = self.orders[index]
                            updatedOrder.status = "Refunded"
                            self.orders[index] = updatedOrder  // trigger view update
                        }
                    }
                } else {
                    print("Refund failed:", decoded.message)
                }
            } catch {
                print("Refund decode failed:", error.localizedDescription)
            }
        }.resume()
    }

    func canCancelOrder(createdAt: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let created = formatter.date(from: createdAt) else { return false }
        return Date().timeIntervalSince(created) < 600 // 10 minutes
    }
}

// MARK: - Order Card View
struct OrderCard: View {
    let order: Order
    let index: Int
    let canCancel: Bool
    let onCancel: () -> Void
    let onRefund: () -> Void
    let onDelivered: () -> Void

    var statusColor: Color {
        switch order.status.lowercased() {
        case "pending": return .orange
        case "delivered": return .green
        case "cancelled": return .red
        case "refunded": return .blue
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Order #\(index + 1)").font(.headline)
                Spacer()

                // Delivered Button (only when pending)
                if order.status.lowercased() == "pending" {
                    Button("Delivered", action: onDelivered)
                        .font(.caption)
                        .padding(6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .buttonStyle(BorderlessButtonStyle())
                }

                // Refund Button (top right)
                if order.status.lowercased() == "cancelled" && order.payment_method == "Google Pay" {
                    Button(action: {
                        print("Refund button tapped for order ID: \(order.id)")
                        onRefund()
                    }) {
                        Text("Refund")
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }

            Text("User: \(order.user_name)")
            Text("Phone: \(order.phone_number)")
            Text("Address: \(order.address)")
            Text("Items: \(order.cart_items)")
            Text("Total: ₹\(order.total_price)").bold()
            Text("Payment: \(order.payment_method)")
            if let txn = order.transaction_id, !txn.isEmpty {
                Text("Transaction ID: \(txn)")
            }
            Text("Delivery Time: \(order.delivery_time)")
            Text("Order Type: \(order.order_type)")
            Text("Created At: \(order.created_at)")
            Text("Status: \(order.status)")
                .padding(5)
                .background(statusColor.opacity(0.2))
                .cornerRadius(6)

            // Move Cancel Button to bottom
            if canCancel && order.status.lowercased() == "pending" {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.caption)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            Divider()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.vertical, 5)
    }
}


// MARK: - Main View
struct MyOrderPage: View {
    @ObservedObject var viewModel = OrderViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Orders...")
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(Array(viewModel.orders.enumerated()), id: \.element.id) { index, order in
                                OrderCard(
                                    order: order,
                                    index: index,
                                    canCancel: viewModel.canCancelOrder(createdAt: order.created_at),
                                    onCancel: { viewModel.cancelOrder(order: order) },
                                    onRefund: { viewModel.refundOrder(order: order) },
                                    onDelivered: { viewModel.markOrderDelivered(order: order) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                }
            }
            .navigationBarTitle("All Orders", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            })
        }
    }
}

// MARK: - Preview
struct MyOrderPage_Previews: PreviewProvider {
    static var previews: some View {
        MyOrderPage()
    }
}

