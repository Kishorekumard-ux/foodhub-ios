import SwiftUI

struct SearchResultsView: View {
    let query: String
    let userName: String
    let phoneNumber: String

    @State private var foodItems: [FoodItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var selectedIndex: Int? = nil

    @EnvironmentObject var favoriteModel: FavoriteModel
    @EnvironmentObject var shoppingCartModel: ShoppingCartModel
    @Environment(\.dismiss) private var dismiss  // For custom back

    struct FoodItem: Identifiable {
        let id = UUID()
        let name: String
        let imageUrl: String
        let category: String
    }

    private func fetchFoodItems() async {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/searchFood.php") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"query\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(query)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            foodItems = decoded.map { item in
                FoodItem(
                    name: item["name"] as? String ?? "Unknown",
                    imageUrl: item["image_url"] as? String ?? "",
                    category: item["category"] as? String ?? "Unknown"
                )
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func destinationView(for category: String, itemName: String) -> some View {
        switch category.lowercased() {
        case "snack":
            return AnyView(SnacksPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel))
        case "veg":
            return AnyView(VegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel))
        case "breakfast":
            return AnyView(BreakfastPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel))
        case "non-veg":
            return AnyView(NonVegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(favoriteModel)
                .environmentObject(shoppingCartModel))
        default:
            return AnyView(Text("Unknown Category"))
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView().onAppear {
                    Task { await fetchFoodItems() }
                }
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if foodItems.isEmpty {
                Text("No items found")
                    .padding()
            } else {
                List(foodItems.indices, id: \.self) { index in
                    let item = foodItems[index]
                    let isSelected = selectedIndex == index
                    NavigationLink(destination: destinationView(for: item.category, itemName: item.name)) {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let img): img.resizable().scaledToFill()
                                case .failure: Image(systemName: "photo").resizable()
                                @unknown default: Image(systemName: "photo")
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(8)

                            Text(item.name)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? .white : .primary)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.blue.opacity(0.7) : Color.clear)
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        if selectedIndex == index {
                            selectedIndex = nil
                        } else {
                            selectedIndex = index
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Search Results for '\(query)'")
        .navigationBarBackButtonHidden(true) // 🔴 Hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: HomeView(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(favoriteModel)
                    .environmentObject(shoppingCartModel)) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                }

            }
        }
    }
}
