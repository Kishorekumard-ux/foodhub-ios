import SwiftUI

    // MARK: - Main Home View
    struct HomeView: View {
        let userName: String
        let phoneNumber: String
        @State private var searchText: String = ""
        @State private var popularFoodItems: [[String: Any]] = []
        @State private var recommendedFoodItems: [[String: Any]] = []
        @State private var timer: Timer?
        @State private var scrollOffset: CGFloat = 0
        @State private var popularError: String? = nil
        @State private var recommendedError: String? = nil
        @EnvironmentObject var cartModel: ShoppingCartModel
        @State private var navigateToSearch = false
        @State private var showAIChat = false
        @State private var showFavorites = false
        @EnvironmentObject var favoriteModel: FavoriteModel

        var body: some View {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    mainContent // Extracted main VStack

                    // --- Update: Use NavigationLink for FAQChatPage avatar ---
                    NavigationLink(
                        destination: FAQChatPage(userName: userName, phoneNumber: phoneNumber)
                    ) {
                        StickyAIButton {
                            // No action needed, handled by NavigationLink
                        }
                        .padding(.bottom, 80)
                        .padding(.trailing, 24)
                    }
                }
                .navigationBarBackButtonHidden(true)

                // Remove .navigationDestination for FAQChatPage and FavoritePage
                .navigationDestination(isPresented: $navigateToSearch) {
                    SearchResultsView(query: searchText, userName: userName, phoneNumber: phoneNumber)
                        .environmentObject(favoriteModel)
                        .environmentObject(cartModel)
                }
            }
        }


        // MARK: - Main Content Extracted
        private var mainContent: some View {
            VStack(spacing: 0) {
                // Sticky Header
                headerSection

                // Main Scrollable Content
                ScrollView {
                    scrollableContent
                }
            }
            .onAppear {
                fetchPopularFoodItems()
                fetchRecommendedFoodItems()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    // Home - current page
                    footerIcon(imagePath: "home", destination: nil)

                    Spacer()

                    // Navigate to FeedbackView
                    footerIcon(imagePath: "user feedback", destination: AnyView(UserFeedbackView(userName: userName)))

                    Spacer()

                    // Navigate to CartView
                    footerIcon(imagePath: "cart", destination: AnyView(CartPage(userName: userName, phoneNumber: phoneNumber).environmentObject(cartModel)))

                    Spacer()

                    // Navigate to ProfileView
                    footerIcon(
                        imagePath: "user",
                        destination: AnyView(
                            AccountPage(userName: userName, phoneNumber: phoneNumber)
                                .environmentObject(favoriteModel) // <-- Use shared instance
                        )
                    )
                    Spacer()

                }
            }
        }

        // MARK: - Header Section Extracted
        private var headerSection: some View {
            VStack(spacing: 0) {
                // Greeting and Profile Image (Row 1)
                HStack {
                    Text("Hi, \(userName)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    Image("page")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .zIndex(2)

                // Search Bar (Row 2)
                HStack {
                    TextField("Find your delicious food", text: $searchText)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Image("search")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        )
                        .foregroundColor(.black)
                        .onSubmit {
                            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                navigateToSearch = true
                            }
                        }
                    Spacer().frame(width: 10)
                    // --- Update: Use NavigationLink for favorite icon ---
                    NavigationLink(
                        destination: FavoritePage(userName: userName, phoneNumber: phoneNumber)
                            .environmentObject(favoriteModel)
                            .environmentObject(cartModel)
                    ) {
                        Image("heart")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 4)
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .zIndex(2)
            }
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
            .zIndex(2)
        }

        // MARK: - Scrollable Content Extracted
        private var scrollableContent: some View {
            VStack {
                Spacer().frame(height: 20)

                // Sliding Images Section
                VStack {
                    TabView {
                        Button(action: {}) {
                            Image("slides1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        Button(action: {}) {
                            Image("slides2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tabViewStyle(PageTabViewStyle())
                }
                .padding(16)

                Spacer().frame(height: 20)

                // Categories Section
                VStack(alignment: .leading) {
                    Text("Categories")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    Spacer().frame(height: 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            categoryItem(name: "Snacks", imagePath: "burger")
                            categoryItem(name: "Breakfast", imagePath: "idly")
                            categoryItem(name: "Veg", imagePath: "veg")
                            categoryItem(name: "Non-Veg", imagePath: "biryani")
                        }
                    }
                }
                .padding(16)

                // Extracted For You Section
                forYouSection

                // Extracted Popular Foods Section
                popularFoodsSection

                Spacer()
            }
            .background(Color.white)
        }

        // MARK: - Section Extracted Views

        private var forYouSection: some View {
            VStack(alignment: .leading) {
                Text("For You")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer().frame(height: 20)

                if let error = recommendedError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if recommendedFoodItems.isEmpty {
                    Text("No recommended food items available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recommendedFoodItems.indices, id: \.self) { idx in
                                let food = recommendedFoodItems[idx]
                                let name = food["name"] as? String ?? ""
                                let imagePath = food["image_url"] as? String ?? ""
                                let category = food["category"] as? String ?? ""

                                foodCardForYou(
                                    name: name,
                                    imagePath: imagePath,
                                    category: category
                                )
                                .id("\(name)-\(imagePath)-\(category)-\(idx)")
                            }
                        }
                    }
                }
            }
            .padding(16)
        }


        private var popularFoodsSection: some View {
            VStack(alignment: .leading) {
                Text("Popular Foods")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer().frame(height: 10)

                if let error = popularError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if popularFoodItems.isEmpty {
                    Text("No popular food items available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(popularFoodItems.indices, id: \.self) { idx in
                                let food = popularFoodItems[idx]
                                let name = food["name"] as? String ?? ""
                                let image = food["image_url"] as? String ?? ""
                                let category = food["category"] as? String ?? ""

                                popularFoodCard(
                                    name: name,
                                    image: image,
                                    category: category
                                )
                                .id("\(name)-\(image)-\(category)-\(idx)")
                            }
                        }
                    }
                }
            }
            .padding(16)
        }

        // MARK: - Category Item Widget
        func categoryItem(name: String, imagePath: String) -> some View {
            VStack {
                // Map category names to destination views
                NavigationLink(destination: categoryDestinationView(for: name)) {
                    Image(imagePath)
                        .resizable()
                        .frame(width: 70, height: 70)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                Spacer().frame(height: 5)
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }

        // Helper to return the correct destination view for each category
        @ViewBuilder
        func categoryDestinationView(for name: String) -> some View {
            switch name.lowercased() {
            case "snacks","snack":
                SnacksPage(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(cartModel)
                    .environmentObject(FavoriteModel())
            case "breakfast":
                BreakfastPage(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(cartModel)
                    .environmentObject(FavoriteModel())
            case "veg":
                VegPage(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(cartModel)
                    .environmentObject(FavoriteModel())
            case "non-veg":
                NonVegPage(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(cartModel)
                    .environmentObject(FavoriteModel())
            default:
                CategoryPage(categoryName: name)
            }
        }

        // MARK: - Food Card For You Widget
        func foodCardForYou(name: String, imagePath: String, category: String) -> some View {
            NavigationLink(destination: categoryDestinationView(for: category)) {
                VStack {
                    // Always treat as URL now, since PHP returns absolute URLs
                    ImageFromURL(url: imagePath)
                        .frame(height: 70)
                        .aspectRatio(contentMode: .fit)
                    Spacer().frame(height: 10)
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 140, height: 140)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
                .padding(.horizontal, 10)
            }
        }

        // MARK: - Popular Food Card Widget
        func popularFoodCard(name: String, image: String, category: String) -> some View {
            NavigationLink(destination: categoryDestinationView(for: category)) {
                VStack(alignment: .leading) {
                    // Always treat as URL now, since PHP returns absolute URLs
                    ImageFromURL(url: image)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(8)
                    Spacer().frame(height: 8)
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 10)
                }
                .background(Color.black)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
        }

        // MARK: - Footer Icon with Optional Navigation
        @ViewBuilder
        func footerIcon(imagePath: String, destination: AnyView?) -> some View {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    Image(imagePath)
                        .resizable()
                        .frame(width: 30, height: 35)
                }
            } else {
                Image(imagePath)
                    .resizable()
                    .frame(width: 30, height: 35)
            }
        }

        // MARK: - Sticky AI Button
        struct StickyAIButton: View {
            var action: () -> Void

            var body: some View {
                Button(action: action) {
                    Image("man") // Replace with your AI image asset name
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.blue.opacity(0.7), radius: 16, x: 0, y: 0)
                                .shadow(color: Color.blue.opacity(0.4), radius: 32, x: 0, y: 0)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .shadow(color: Color.blue, radius: 8)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }

        // MARK: - Networking
        func fetchPopularFoodItems() {
            guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/popular_foods.php") else {
                let msg = "Failed to build: Invalid URL for popular food items"
                print(msg)
                popularError = msg
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // If your PHP expects form data, you can send an empty body or add parameters as needed
            request.httpBody = "".data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    let msg = "Failed to build: Error fetching popular food items: \(error)"
                    print(msg)
                    DispatchQueue.main.async { self.popularError = msg }
                    return
                }
                guard let data = data else {
                    let msg = "Failed to build: No data received for popular food items"
                    print(msg)
                    DispatchQueue.main.async { self.popularError = msg }
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], !json.isEmpty {
                        DispatchQueue.main.async {
                            self.popularFoodItems = Array(json.prefix(6))
                            self.popularError = nil
                        }
                    } else {
                        let msg = "Failed to build: Could not decode popular food items response"
                        print(msg)
                        DispatchQueue.main.async { self.popularError = msg }
                    }
                } catch {
                    let msg = "Failed to build: Error decoding: \(error.localizedDescription)"
                    print(msg)
                    DispatchQueue.main.async { self.popularError = msg }
                }
            }.resume()
        }

        func fetchRecommendedFoodItems() {
            guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/random_foods.php") else {
                let msg = "Failed to build: Invalid URL for recommended food items"
                print(msg)
                recommendedError = msg
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // If your PHP expects a category, you can add it here. For now, send empty body.
            request.httpBody = "".data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    let msg = "Failed to build: Error fetching recommended food items: \(error)"
                    print(msg)
                    DispatchQueue.main.async { self.recommendedError = msg }
                    return
                }
                guard let data = data else {
                    let msg = "Failed to build: No data received"
                    print(msg)
                    DispatchQueue.main.async { self.recommendedError = msg }
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], !json.isEmpty {
                        DispatchQueue.main.async {
                            self.recommendedFoodItems = Array(json.prefix(6))
                            self.recommendedError = nil
                        }
                    } else {
                        let msg = "Failed to build: Could not decode recommended food items"
                        print(msg)
                        DispatchQueue.main.async { self.recommendedError = msg }
                    }
                } catch {
                    let msg = "Failed to build: Error decoding: \(error.localizedDescription)"
                    print(msg)
                    DispatchQueue.main.async { self.recommendedError = msg }
                }
            }.resume()
        }
    }

    // MARK: - Image Loader
    struct ImageFromURL: View {
        let url: String
        @State private var loadedImage: UIImage? = nil

        var body: some View {
            Group {
                if let img = loadedImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onAppear(perform: loadImage)
                }
            }
        }

        private func loadImage() {
            guard let imageURL = URL(string: url) else { return }
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.loadedImage = uiImage
                    }
                }
            }.resume()
        }
    }

    // MARK: - Preview
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(userName: "User", phoneNumber: "1234567890")
                .environmentObject(ShoppingCartModel())
                .environmentObject(FavoriteModel())
        }
    }



    // MARK: - Category Page Destination
    // MARK: - Category Pages
    struct CategoryPage: View {
        let categoryName: String

        var body: some View {
            Text("\(categoryName) Page")
                .font(.largeTitle)
                .bold()
                .navigationTitle(categoryName)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    struct snackspage: View {
        var body: some View {
            Text("Snacks Page")
                .font(.largeTitle)
                .bold()
                .navigationTitle("Snacks")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct breakfastpage: View {
        var body: some View {
            Text("Breakfast Page")
                .font(.largeTitle)
                .bold()
                .navigationTitle("Breakfast")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct vegpage: View {
        var body: some View {
            Text("Veg Page")
                .font(.largeTitle)
                .bold()
                .navigationTitle("Veg")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct nonvegpage: View {
        var body: some View {
            Text("Non-Veg Page")
                .font(.largeTitle)
                .bold()
                .navigationTitle("Non-Veg")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
