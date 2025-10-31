import SwiftUI
import Combine

struct FavoritePage: View {
    @EnvironmentObject var favoriteModel: FavoriteModel
    @EnvironmentObject var shoppingCartModel: ShoppingCartModel  // Required for navigation to cart-related pages

    // Passed from parent view
    let userName: String
    let phoneNumber: String

    var body: some View {
        NavigationStack {
            VStack {
                if favoriteModel.items.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No favorites yet.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(favoriteModel.items) { item in
                            ZStack {
                                NavigationLink(destination: destinationView(for: item.category)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                HStack(spacing: 16) {
                                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        case .failure:
                                            Color.gray
                                        @unknown default:
                                            Color.gray
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text("₹\(item.price)")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }

                                    Spacer()

                                    Button(action: {
                                        favoriteModel.remove(item)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        favoriteModel.loadFromUserDefaults()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    // MARK: - Category-based navigation with environment objects
    @ViewBuilder
    func destinationView(for category: String) -> some View {
        switch category.lowercased() {
        case "veg":
            VegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel)
        case "nonveg", "non-veg":
            NonVegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel)
        case "snack", "snacks":
            SnacksPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel)
        case "breakfast":
            BreakfastPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel)
        default:
            Text("Unknown Category")
                .foregroundColor(.gray)
                .font(.title)
        }
    }
}

#Preview {
    FavoritePage(userName: "John Doe", phoneNumber: "9876543210")
        .environmentObject(FavoriteModel())
        .environmentObject(ShoppingCartModel())
}
