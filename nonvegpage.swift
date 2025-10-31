import SwiftUI
import Combine

// MARK: - Models

struct NonVeg: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let price: Double
    let original_price: Double?
    let discount_percent: Double?
    let description: String
    let image_url: String
    let is_available: Bool
    let stock_level: Int
}

struct NonVegResponse: Codable {
    let message: String
    let data: [NonVeg]
}

// MARK: - ViewModels

class NonVegViewModel: ObservableObject {
    @Published var nonvegs: [NonVeg] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var lastMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchNonVegs()
    }

    func fetchNonVegs() {
        isLoading = true
        let category = "non-veg"
        let search = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var request = URLRequest(url: URL(string: "http://14.139.187.229:8081/mca/foodhub/snackspage.php")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "category=\(category)&search=\(search)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: NonVegResponse.self, decoder: JSONDecoder())
            .replaceError(with: NonVegResponse(message: "Failed", data: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.nonvegs = response.data
                self?.lastMessage = response.message
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func updatePopularity(foodId: String) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/update_popularity.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "food_id=\(foodId)".data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
}

class NonVegWishlistModel: ObservableObject {
    @Published var items: Set<String> = []

    func toggle(nonveg: NonVeg) {
        let nonvegId = String(nonveg.id)
        if items.contains(nonvegId) {
            items.remove(nonvegId)
        } else {
            items.insert(nonvegId)
        }
    }

    func contains(_ nonveg: NonVeg) -> Bool {
        items.contains(String(nonveg.id))
    }
}

// MARK: - Views

struct NonVegPage: View {
    @StateObject private var viewModel = NonVegViewModel()
    @EnvironmentObject var cart: ShoppingCartModel
    @EnvironmentObject var favoriteModel: FavoriteModel
    @StateObject private var wishlist = NonVegWishlistModel()
    @State private var showFavorites = false
    let userName: String
    let phoneNumber: String
    let category = "non-veg"

    var body: some View {
        NavigationStack {
            VStack {
                // Search & Cart
                HStack {
                    TextField("Find your favorite non-veg...", text: $viewModel.searchQuery, onCommit: {
                        viewModel.fetchNonVegs()
                    })
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .padding(.horizontal)

                    NavigationLink(destination: CartPage(userName: userName, phoneNumber: phoneNumber).environmentObject(cart)) {
                        Image(systemName: "cart")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(.trailing)
                    }
                }
                .padding(.top, 10)

                if viewModel.isLoading {
                    ProgressView("Loading...").padding()
                } else if viewModel.nonvegs.isEmpty {
                    VStack {
                        Image(systemName: "leaf")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No non-veg items available.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.nonvegs, id: \.id) { nonveg in
                            NonVegCard(
                                nonveg: nonveg,
                                isInWishlist: wishlist.contains(nonveg),
                                onAddToCart: { quantity in
                                    let cartItem = CartItem(
                                        id: nonveg.id,
                                        name: nonveg.name,
                                        description: nonveg.description,
                                        price: Double(nonveg.price),
                                        imageUrl: nonveg.image_url,
                                        quantity: quantity
                                    )
                                    cart.add(item: cartItem)
                                    viewModel.updatePopularity(foodId: String(nonveg.id))
                                },
                                onToggleWishlist: {
                                    wishlist.toggle(nonveg: nonveg)
                                }
                            )
                            .environmentObject(favoriteModel)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Non-Veg")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Use NavigationLink directly for the favorite icon
                    NavigationLink(
                        destination: FavoritePage(userName: userName, phoneNumber: phoneNumber)
                            .environmentObject(favoriteModel)
                            .environmentObject(cart) 
                    ) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct NonVegCard: View {
    let nonveg: NonVeg
    let isInWishlist: Bool
    var onAddToCart: (Int) -> Void
    var onToggleWishlist: () -> Void

    @EnvironmentObject var favoriteModel: FavoriteModel

    @State private var quantity = 1
    @State private var showAddedToCart = false
    @State private var showImagePreview = false

    let category = "non-veg"

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // --- NonVeg Image ---
                    AsyncImage(url: URL(string: nonveg.image_url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    showImagePreview = true
                                }
                        case .failure:
                            Color.gray
                        @unknown default:
                            Color.gray
                        }
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .sheet(isPresented: $showImagePreview) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            VStack {
                                Spacer()
                                AsyncImage(url: URL(string: nonveg.image_url)) { phase in
                                    if case let .success(largeImage) = phase {
                                        largeImage
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                    } else {
                                        ProgressView()
                                    }
                                }
                                Spacer()
                                Button("Close") {
                                    showImagePreview = false
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                                .padding(.bottom)
                            }
                        }
                    }

                    // --- NonVeg Info ---
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(nonveg.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                let favItem = FavoriteItem(
                                    id: nonveg.id,
                                    name: nonveg.name,
                                    price: Int(nonveg.price),
                                    imageUrl: nonveg.image_url,
                                    category: category,
                                    quantity: quantity
                                )
                                favoriteModel.toggle(favItem)
                            }) {
                                Image(systemName: favoriteModel.containsItemId(nonveg.id, in: category) ? "heart.fill" : "heart")
                                    .foregroundColor(favoriteModel.containsItemId(nonveg.id, in: category) ? .red : .gray)
                            }
                        }

                        Text(nonveg.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)

                        HStack {
                            Text("₹\(Int(nonveg.price))")
                                .font(.headline)
                                .foregroundColor(.red)

                            HStack(spacing: 6) {
                                Button {
                                    if quantity > 1 { quantity -= 1 }
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(.plain)

                                Text("\(quantity)")
                                    .frame(width: 24)

                                Button {
                                    quantity += 1
                                } label: {
                                    Image(systemName: "plus.circle")
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.leading, 8)

                            Spacer()

                            Button {
                                if nonveg.is_available {
                                    onAddToCart(quantity)
                                    showAddedToCart = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        showAddedToCart = false
                                    }
                                }
                            } label: {
                                Image(systemName: showAddedToCart ? "checkmark.circle.fill" : "cart")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black).frame(width: 40, height: 40))
                            }
                            .buttonStyle(.plain)
                        }

                        if !nonveg.is_available {
                            Text("Currently unavailable")
                                .font(.caption)
                                .foregroundColor(.red)
                                .bold()
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.vertical, 6)

            // Discount Banner (top left)
            if let discount = nonveg.discount_percent, discount > 0 {
                Text("-\(Int(discount))% OFF")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8, corners: [.topLeft, .bottomRight])
                    .padding([.top, .leading], 8)
            }
        }
    }
}
//
//// Helper extension for corner radius on specific corners
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape( RoundedCorner(radius: radius, corners: corners) )
//    }
//}
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}

// MARK: - Preview

#Preview {
    NonVegPage(userName: "John Doe", phoneNumber: "1234567890")
        .environmentObject(ShoppingCartModel())
        .environmentObject(FavoriteModel())
}
