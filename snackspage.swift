import SwiftUI
import Combine

// MARK: - Models

struct Snack: Identifiable, Codable, Hashable {
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

struct SnackResponse: Codable {
    let message: String
    let data: [Snack]
}

// MARK: - ViewModels

class SnacksViewModel: ObservableObject {
    @Published var snacks: [Snack] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var lastMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchSnacks()
    }

    func fetchSnacks() {
        isLoading = true
        let category = "snack"
        let search = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var request = URLRequest(url: URL(string: "http://14.139.187.229:8081/mca/foodhub/snackspage.php")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "category=\(category)&search=\(search)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SnackResponse.self, decoder: JSONDecoder())
            .replaceError(with: SnackResponse(message: "Failed", data: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.snacks = response.data
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

class CartModel: ObservableObject {
    @Published var items: [Snack: Int] = [:]
    
    func add(snack: Snack, quantity: Int) {
        items[snack, default: 0] += quantity
    }
}

class WishlistModel: ObservableObject {
    @Published var items: Set<String> = []

    func toggle(snack: Snack) {
        let snackId = String(snack.id) // Convert Int to String for consistency
        if items.contains(snackId) {
            items.remove(snackId)
        } else {
            items.insert(snackId)
        }
    }

    func contains(_ snack: Snack) -> Bool {
        items.contains(String(snack.id))
    }
}

// MARK: - Views
struct SnacksPage: View {
    @StateObject private var viewModel = SnacksViewModel()
    @EnvironmentObject var cart: ShoppingCartModel
    @EnvironmentObject var favoriteModel: FavoriteModel
    @StateObject private var wishlist = WishlistModel()
    @State private var showFavorites = false
    let userName: String
    let phoneNumber: String
    let category = "snack"

    var body: some View {
        NavigationStack {
            VStack {
                // Search & Cart
                
                HStack {
                    TextField("Find your favorite snack...", text: $viewModel.searchQuery, onCommit: {
                        viewModel.fetchSnacks()
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
                } else if viewModel.snacks.isEmpty {
                    VStack {
                        Image(systemName: "leaf")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No snack items available.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.snacks, id: \.id) { snack in
                            SnackCard(
                                snack: snack,
                                isInWishlist: wishlist.contains(snack),
                                onAddToCart: { quantity in
                                    // Add to ShoppingCartModel
                                    let cartItem = CartItem(
                                        id: snack.id,
                                        name: snack.name,
                                        description: snack.description,
                                        price: Double(snack.price),
                                        imageUrl: snack.image_url,
                                        quantity: quantity
                                    )
                                    cart.add(item: cartItem)
                                    viewModel.updatePopularity(foodId: String(snack.id))
                                },
                                onToggleWishlist: {
                                    wishlist.toggle(snack: snack)
                                }
                            )
                            .environmentObject(favoriteModel)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Snacks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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

struct SnackCard: View {
    let snack: Snack
    let isInWishlist: Bool
    var onAddToCart: (Int) -> Void
    var onToggleWishlist: () -> Void
    
    @EnvironmentObject var favoriteModel: FavoriteModel
    
    @State private var quantity = 1
    @State private var showAddedToCart = false
    @State private var showImagePreview = false
    
    let category = "snack"
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // --- Snack Image ---
                    AsyncImage(url: URL(string: snack.image_url)) { phase in
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
                                AsyncImage(url: URL(string: snack.image_url)) { phase in
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
                    
                    // --- Snack Info ---
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(snack.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                let favItem = FavoriteItem(
                                    id: snack.id,
                                    name: snack.name,
                                    price: Int(snack.price),
                                    imageUrl: snack.image_url,
                                    category: category,
                                    quantity: quantity
                                )
                                favoriteModel.toggle(favItem)
                            }) {
                                Image(systemName: favoriteModel.containsItemId(snack.id, in: category) ? "heart.fill" : "heart")
                                    .foregroundColor(favoriteModel.containsItemId(snack.id, in: category) ? .red : .gray)
                            }
                        }
                        
                        Text(snack.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        HStack {
                            Text("₹\(Int(snack.price))")
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
                                if snack.is_available {
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
                        
                        if !snack.is_available {
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
            if let discount = snack.discount_percent, discount > 0 {
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

// Helper extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    SnacksPage(userName: "John Doe", phoneNumber: "1234567890")
        .environmentObject(ShoppingCartModel())
        .environmentObject(FavoriteModel())
}
