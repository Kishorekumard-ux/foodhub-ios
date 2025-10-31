import SwiftUI

// MARK: - Checkout Page

struct CheckoutPageView: View {
    let totalPrice: Int
    let totalItems: Int
    let cartItems: [CartItem]
    let userName: String
    let phoneNumber: String

    @State private var couponCode = ""
    @State private var discount: Double = 0.0
    @State private var deliveryAddress = ""
    @State private var description = ""
    @State private var isBulkOrder = false
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPaymentPage = false

    var calculatedTotal: Double {
        max(Double(totalPrice) - discount, 0)
    }

    var paymentDestination: PaymentPage {
        PaymentPage(
            totalPrice: Int(calculatedTotal),
            totalItems: totalItems,
            cartItems: cartItems,
            address: deliveryAddress,
            orderType: isBulkOrder ? "Bulk" : "Regular",
            deliveryDate: isBulkOrder ? selectedDate : nil,
            deliveryTime: selectedTime,
            userName: userName,
            phoneNumber: phoneNumber,
            description: description
        )
    }

    // All possible coupons with their requirements
    let allCoupons: [(code: String, description: String, minAmount: Int)] = [
        ("CASHBACK100", "₹100 cashback on orders above ₹1000", 1001),
        ("20PERCENT", "20% off on orders above ₹500", 501),
        ("FIRST10", "10% off for first order", 0)
    ]

    // Best coupon code for the current totalPrice
    var bestCouponCode: String {
        if totalPrice > 1000 {
            return "CASHBACK100"
        } else if totalPrice > 500 {
            return "20PERCENT"
        } else {
            return "FIRST10"
        }
    }

    // Filtered coupon suggestions based on input and totalPrice
    var filteredCouponSuggestions: [(code: String, description: String)] {
        allCoupons
            .filter { coupon in
                (coupon.minAmount == 0 || totalPrice >= coupon.minAmount)
                && (couponCode.isEmpty || coupon.code.lowercased().contains(couponCode.lowercased()))
            }
            .map { ($0.code, $0.description) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Order Summary
                Text("🧾 Order Summary")
                    .font(.title2)
                    .bold()

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(cartItems) { item in
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray
                                }
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("\(item.quantity) × ₹\(Int(item.price)) = ₹\(Int(item.price * Double(item.quantity)))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }

                // MARK: - Coupon Section
                Group {
                    Text("🎟️ Apply Coupon")
                        .font(.headline)

                    HStack {
                        TextField("Enter coupon code", text: $couponCode)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onAppear {
                                // Pre-fill the best coupon code based on totalPrice if not already set
                                if couponCode.isEmpty {
                                    couponCode = bestCouponCode
                                }
                            }
                            .onChange(of: totalPrice) { oldValue, newValue in
                                if couponCode.isEmpty || allCoupons.first(where: { $0.code == couponCode }) == nil {
                                    couponCode = bestCouponCode
                                }
                            }

                            .onSubmit { applyCoupon() }

                        Button(action: applyCoupon) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }

                    // Show the description of the suggested coupon
                    if let coupon = allCoupons.first(where: { $0.code == couponCode }) {
                        Text(coupon.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                    }

                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("₹\(totalPrice)")
                    }

                    if discount > 0 {
                        HStack {
                            Text("Discount")
                            Spacer()
                            Text("-₹\(Int(discount))")
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Text("Total Payable")
                            .font(.headline)
                        Spacer()
                        Text("₹\(Int(calculatedTotal))")
                            .bold()
                    }
                }

                Divider()

                // MARK: - Delivery Address
                Group {
                    Text("🏠 Delivery Address")
                        .font(.headline)
                    TextField("Building, Street, City", text: $deliveryAddress)
                        .textFieldStyle(.roundedBorder)
                }

                // MARK: - Order Type
                Group {
                    Text("📦 Order Type")
                        .font(.headline)
                    Picker("Order Type", selection: $isBulkOrder) {
                        Text("Regular Order").tag(false)
                        Text("Bulk Order").tag(true)
                    }
                    .pickerStyle(.segmented)

                    DatePicker("📅 Select Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        .disabled(!isBulkOrder)

                    DatePicker("⏰ Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }

                // MARK: - Description & Button
                Group {
                    Text("📝 Order Description")
                        .font(.headline)
                    TextField("Describe your order...", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 100)

                    Button(action: {
                        if deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty {
                            showAlert(message: "Please enter the delivery address.")
                            return
                        }

                        if isBulkOrder {
                            if selectedDate < Calendar.current.date(byAdding: .day, value: 2, to: Date())! {
                                showAlert(message: "Bulk orders must be scheduled at least 2 days in advance.")
                                return
                            }
                        } else {
                            let now = Date()
                            let calendar = Calendar.current
                            let selectedTodayTime = calendar.date(
                                bySettingHour: calendar.component(.hour, from: selectedTime),
                                minute: calendar.component(.minute, from: selectedTime),
                                second: 0,
                                of: now
                            ) ?? now

                            if selectedTodayTime < now.addingTimeInterval(3600) {
                                showAlert(message: "Regular orders must be scheduled at least 1 hour in advance.")
                                return
                            }
                        }


                        showPaymentPage = true
                    }) {
                        Text("Proceed to Payment")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Checkout")
        // Use navigationDestination for payment page navigation
        .navigationDestination(isPresented: $showPaymentPage) {
            paymentDestination
        }
    }

    // MARK: - Coupon Logic
    func applyCoupon() {
        let code = couponCode.uppercased()
        if code == "20PERCENT", totalPrice > 500 {
            discount = Double(totalPrice) * 0.2
            alertMessage = "✅ 20% discount applied!"
        } else if code == "CASHBACK100", totalPrice > 1000 {
            discount = 100
            alertMessage = "✅ ₹100 cashback applied!"
        } else if code == "FIRST10" {
            discount = Double(totalPrice) * 0.1
            alertMessage = "✅ 10% discount applied!"
        } else {
            discount = 0
            alertMessage = "❌ Invalid or inapplicable coupon."
        }
        showAlert = true
    }

    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CheckoutPageView(
            totalPrice: 1200,
            totalItems: 3,
            cartItems: [
                CartItem(id: 1, name: "Paneer Butter Masala", description: "Delicious curry", price: 250, imageUrl: "", quantity: 2),
                CartItem(id: 2, name: "Veg Biryani", description: "Spicy rice", price: 200, imageUrl: "", quantity: 1)
            ],
            userName: "Kishore Kumar",
            phoneNumber: "9876543210"
        )
    }
}

