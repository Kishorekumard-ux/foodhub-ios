import SwiftUI

// MARK: - Model
struct UserOrder: Identifiable, Codable {
    let id: Int
    let user_name: String
    let phone_number: String
    let address: String
    let order_type: String
    let delivery_date: String?
    let delivery_time: String
    let total_items: Int
    let total_price: String
    let payment_method: String
    let cart_items: String
    let created_at: String
    var status: String

    var statusDisplay: String {
        return status.lowercased() == "cancelled" ? "Refund in Process" : status.capitalized
    }

    var canCancel: Bool {
        guard status.lowercased() == "pending" else { return false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let created = formatter.date(from: created_at) else { return false }

        let timeDiff = Date().timeIntervalSince(created)
        return timeDiff <= 600 // 10 minutes in seconds
    }
}

struct UserOrderResponse: Codable {
    let success: Bool
    let data: [UserOrder]
    let message: String?
}

// MARK: - ViewModel
class UserOrderViewModel: ObservableObject {
    @Published var orders: [UserOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let phoneNumber: String

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        fetchUserOrders()
    }

    func fetchUserOrders() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/get_user_orders.php") else {
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "phoneNumber=\(phoneNumber)".data(using: .utf8)

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async { self.isLoading = false }

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ Network error occurred."
                }
                return
            }

            do {
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Raw response:\n\(raw)")
                }

                let decodedResponse = try JSONDecoder().decode(UserOrderResponse.self, from: data)

                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self.orders = decodedResponse.data.sorted(by: { $0.created_at > $1.created_at })
                        self.errorMessage = self.orders.isEmpty ? "No orders found." : nil
                    } else {
                        self.errorMessage = decodedResponse.message ?? "⚠️ Failed to fetch orders."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - View
struct MyUserOrdersPage: View {
    let phoneNumber: String
    @StateObject private var viewModel: UserOrderViewModel

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        _viewModel = StateObject(wrappedValue: UserOrderViewModel(phoneNumber: phoneNumber))
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("My Orders")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading your orders...")
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
        } else if let message = viewModel.errorMessage {
            Text(message)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            if viewModel.orders.isEmpty {
                Text("🛒 No orders found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.orders) { order in
                        UserOrderRow(
                            order: order,
                            onStatusChange: { updatedOrder in
                                if let index = viewModel.orders.firstIndex(where: { $0.id == updatedOrder.id }) {
                                    viewModel.orders[index] = updatedOrder
                                    viewModel.orders = viewModel.orders.map { $0.id == updatedOrder.id ? updatedOrder : $0 }
                                }
                            },
                            onOrderCancelled: {
                                viewModel.fetchUserOrders()
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Order Card View
struct UserOrderRow: View {
    @State private var orderCopy: UserOrder
    @State private var isCancelling = false
    @State private var showRefundAnimation = false
    @State private var animateOpacity = false

    let onStatusChange: (UserOrder) -> Void
    let onOrderCancelled: () -> Void

    init(order: UserOrder, onStatusChange: @escaping (UserOrder) -> Void, onOrderCancelled: @escaping () -> Void) {
        _orderCopy = State(initialValue: order)
        self.onStatusChange = onStatusChange
        self.onOrderCancelled = onOrderCancelled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order ID: \(orderCopy.id)").font(.headline)
                Spacer()
                if showRefundAnimation {
                    AnimatedRefundText()
                } else {
                    Text(orderCopy.statusDisplay)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(statusColor)
                        .cornerRadius(8)
                }
            }

            Text("Name: \(orderCopy.user_name)")
            Text("Address: \(orderCopy.address)")
            Text("Items: \(orderCopy.cart_items)")
            Text("Total Items: \(orderCopy.total_items)")
            Text("Total: ₹\(orderCopy.total_price)").bold()
            Text("Payment: \(orderCopy.payment_method)")
            Text("Delivery: \(orderCopy.delivery_date ?? "N/A") at \(orderCopy.delivery_time)")
            Text("Order Type: \(orderCopy.order_type)")
            Text("Ordered At: \(orderCopy.created_at)")

            if orderCopy.canCancel && !showRefundAnimation {
                Button(action: cancelOrder) {
                    Text(isCancelling ? "Cancelling..." : "Cancel Order")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(isCancelling)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
        .padding(.vertical, 6)
    }

    var statusColor: Color {
        switch orderCopy.status.lowercased() {
        case "pending": return .orange
        case "delivered": return .green
        case "cancelled": return .blue
        default: return .gray
        }
    }

    func cancelOrder() {
        // Instantly update UI
        orderCopy.status = "cancelled"
        showRefundAnimation = true
        isCancelling = true

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/cancel_order.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "orderId=\(orderCopy.id)".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isCancelling = false
            }

            guard let data = data, error == nil else { return }

            if let response = try? JSONDecoder().decode([String: Bool].self, from: data),
               response["success"] == true {
                DispatchQueue.main.async {
                    // Already updated UI above, just notify parent
                    onStatusChange(orderCopy)
                    onOrderCancelled()
                }
            }
        }.resume()
    }
}

// Animated "Refund in Progress" text
struct AnimatedRefundText: View {
    @State private var animate = false

    var body: some View {
        Text("Refund in Progress")
            .font(.caption)
            .foregroundColor(.white)
            .padding(6)
            .background(Color.blue)
            .cornerRadius(8)
            .opacity(animate ? 0.4 : 1)
            .animation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
    }
}

// MARK: - Preview
struct MyUserOrdersPage_Previews: PreviewProvider {
    static var previews: some View {
        MyUserOrdersPage(phoneNumber: "9876543210")
    }
}
