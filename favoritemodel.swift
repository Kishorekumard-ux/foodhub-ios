import SwiftUI
import Combine

struct FavoriteItem: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let price: Int
    let imageUrl: String
    let category: String
    var quantity: Int
}

class FavoriteModel: ObservableObject {
    @Published var items: [FavoriteItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }

    // MARK: - Public Methods

    func add(_ item: FavoriteItem) {
        if let index = items.firstIndex(where: { $0.id == item.id && $0.category == item.category }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
    }

    func remove(_ item: FavoriteItem) {
        items.removeAll { $0.id == item.id && $0.category == item.category }
    }

    func updateQuantity(for item: FavoriteItem, to quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id && $0.category == item.category }) {
            if quantity > 0 {
                items[index].quantity = quantity
            } else {
                remove(item)
            }
        }
    }

    func incrementQuantity(for item: FavoriteItem) {
        if let index = items.firstIndex(where: { $0.id == item.id && $0.category == item.category }) {
            items[index].quantity += 1
        }
    }

    func decrementQuantity(for item: FavoriteItem) {
        if let index = items.firstIndex(where: { $0.id == item.id && $0.category == item.category }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                remove(item)
            }
        }
    }

    func toggle(_ item: FavoriteItem) {
        if contains(item) {
            remove(item)
        } else {
            add(item)
        }
    }

    func contains(_ item: FavoriteItem) -> Bool {
        items.contains { $0.id == item.id && $0.category == item.category }
    }

    func containsItemId(_ id: Int, in category: String) -> Bool {
        items.contains { $0.id == id && $0.category == category }
    }

    func favorites(in category: String) -> [FavoriteItem] {
        items.filter { $0.category == category }
    }

    var allFavorites: [FavoriteItem] {
        items
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Persistence

    private let favoritesKey = "favorite_items"

    init() {
        loadFromUserDefaults()
    }

    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    // Make this public for manual refresh
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let savedItems = try? JSONDecoder().decode([FavoriteItem].self, from: data) {
            self.items = savedItems
        }
    }
}

