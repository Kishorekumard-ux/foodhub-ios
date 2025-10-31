import SwiftUI

// MARK: - Main Cart Page

struct CartPage: View {
    @EnvironmentObject var cart: ShoppingCartModel
    @State private var showCheckout = false

    let userName: String
    let phoneNumber: String

    var body: some View {
        NavigationStack {
            VStack {
                if cart.items.isEmpty {
                    Text("Your cart is empty.")
                        .font(.headline)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(cart.items, id: \.id) { item in
                                CartItemRowView(item: item)
                                    .environmentObject(cart)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }

                    VStack(spacing: 16) {
                        Text("Total: ₹\(Int(cart.totalPrice))")
                            .font(.title2)
                            .bold()

                        // ✅ NavigationLink instead of .navigationDestination
                        NavigationLink(
                            destination: CheckoutPageView(
                                totalPrice: Int(cart.totalPrice),
                                totalItems: cart.items.reduce(0) { $0 + $1.quantity },
                                cartItems: cart.items,
                                userName: userName,
                                phoneNumber: phoneNumber
                            ),
                            isActive: $showCheckout
                        ) {
                            EmptyView()
                        }

                        Button(action: {
                            showCheckout = true
                        }) {
                            Text("Checkout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Cart")
        }
    }
}

// MARK: - Cart Item Row View

struct CartItemRowView: View {
    let item: CartItem
    @EnvironmentObject var cart: ShoppingCartModel

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray
                @unknown default:
                    Color.gray
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text("₹\(Int(item.price)) × \(item.quantity) = ₹\(Int(item.price * Double(item.quantity)))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    cart.decrementQuantity(for: item)
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)

                Text("\(item.quantity)")
                    .frame(minWidth: 20)

                Button {
                    cart.incrementQuantity(for: item)
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            Button {
                cart.remove(item: item)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - Preview

#Preview {
    CartPage(userName: "John Doe", phoneNumber: "9876543210")
        .environmentObject(ShoppingCartModel())
}
