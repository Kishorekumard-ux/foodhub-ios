import Foundation
import Combine

// Represents a single food item in the cart
struct CartItem: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    var quantity: Int
}

// Manages the overall cart
class ShoppingCartModel: ObservableObject {
    @Published var items: [CartItem] = [] {
        didSet {
            saveCartToUserDefaults()
        }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    // Add or update an item
    func add(item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
    }

    // Remove an item completely
    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    // Update quantity directly
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                items[index].quantity = quantity
            } else {
                remove(item: item)
            }
        }
    }

    // Increment quantity
    func incrementQuantity(for item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
    }

    // Decrement quantity
    func decrementQuantity(for item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            remove(item: item)
        }
    }

    // Clear the entire cart
    func clearCart() {
        items.removeAll()
    }

    // MARK: - Persistence

    private let cartKey = "shopping_cart_items"

    init() {
        loadCartFromUserDefaults()
    }

    private func saveCartToUserDefaults() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }

    private func loadCartFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let savedItems = try? JSONDecoder().decode([CartItem].self, from: data) {
            self.items = savedItems
        }
    }

    // Optional: Debug print
    func printDebugCart() {
        print("Cart contains:")
        for item in items {
            print("- \(item.name): \(item.quantity)")
        }
    }
}


