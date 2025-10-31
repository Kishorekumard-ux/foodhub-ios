import SwiftUI
import CoreLocation
import UIKit

struct FAQ: Identifiable, Decodable {
    var id = Int()
    let question: String
    let answer: String
}
struct MenuItem: Identifiable, Codable {
    let id: Int
    let name: String
    let image_url: String?
}
struct UserFAQ: Identifiable, Codable {
    var id: UUID = UUID()
    let question: String
    let answer: String?
    let status: String
    let created_at: String

    // Custom decoding to handle missing id from backend
    enum CodingKeys: String, CodingKey {
        case id, question, answer, status, created_at
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Try to decode id as UUID or Int, fallback to UUID()
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            id = uuid
        } else if let intId = try? container.decodeIfPresent(Int.self, forKey: .id) {
            id = UUID(uuidString: String(format: "%08X-%04X-%04X-%04X-%012X", intId, 0, 0, 0, 0)) ?? UUID()
        } else {
            id = UUID()
        }
        question = try container.decode(String.self, forKey: .question)
        answer = try? container.decodeIfPresent(String.self, forKey: .answer)
        status = try container.decode(String.self, forKey: .status)
        created_at = try container.decode(String.self, forKey: .created_at)
    }
    // Default initializer for manual creation
    init(id: UUID = UUID(), question: String, answer: String?, status: String, created_at: String) {
        self.id = id
        self.question = question
        self.answer = answer
        self.status = status
        self.created_at = created_at
    }
}



class FAQViewModel: ObservableObject {
    @Published var faqs: [FAQ] = []
    @Published var conversation: [(role: String, text: String)] = []
    @Published var isTyping = false
    @Published var offerMsg: String?
    @Published var offerCategory: String?
    @Published var weather: String = "🌤️ Fetching weather..."
    @Published var input: String = ""
    // Use category names matching the backend (case-sensitive)
    @Published var categories: [String] = ["Snack", "Breakfast", "Veg", "Non-Veg"]
    @Published var selectedCategory: String?
    @Published var categoryFoods: [MenuItem] = []
    @Published var userFAQs: [UserFAQ] = []

    // Add "Breakfast" to chatCategories
    @Published var chatSelectingCategory = false
    @Published var chatSelectingFood = false
    @Published var chatCategoryFoods: [MenuItem] = []
    @Published var chatCategories: [String] = ["Snack", "Breakfast", "Veg", "Non-Veg"]
    @Published var chatSelectedCategory: String?
    @Published var chatFoodLoading = false
    @Published var chatNoFoodFound = false
    
    init() {
        fetchFAQs()
        fetchOffer()
        fetchWeather()
    }
    
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<20: return "Good evening"
        default: return "Good night"
        }
    }
    
    func fetchFAQs(searchQuery: String = "") {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/faq.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "q=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return }
            if let decoded = try? JSONDecoder().decode([FAQ].self, from: data) {
                DispatchQueue.main.async { self.faqs = decoded }
            }
        }.resume()
    }
    func fetchMyFAQs(phoneNumber: String) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/fetch_user_faq.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = "phone_number=\(phoneNumber)"
        request.httpBody = bodyData.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let faqs = try JSONDecoder().decode([UserFAQ].self, from: data)
                DispatchQueue.main.async {
                    self.userFAQs = faqs
                }
            } catch {
                print("Error decoding userFAQs:", error)
            }
        }.resume()
    }


    func fetchOffer() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/get_best_offer.php") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let category = json["category"] as? String,
               let discount = json["discount"] as? Int {
                DispatchQueue.main.async {
                    self.offerCategory = category
                    self.offerMsg = "🔥 Today's Offer: \(discount)% off on \(category.capitalized)"
                }
            }
        }.resume()
    }
    
    func fetchWeather() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.weather = "🌤️ 28°C, Clear in Chennai"
        }
    }
    
    func handleQuestion(_ question: String) {
        conversation.append((role: "user", text: question))
        isTyping = true
        let matches = faqs.filter { $0.question.lowercased().contains(question.lowercased()) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isTyping = false
            if let match = matches.first {
                self.conversation.append((role: "ai", text: match.answer))
            } else {
                self.conversation.append((role: "ai", text: "Sorry, I couldn't find an answer for that."))
            }
        }
    }
    func fetchFoods(for category: String, forChat: Bool = false, completion: (() -> Void)? = nil) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/get_category_foods.php") else {
            if forChat {
                self.chatCategoryFoods = []
                self.chatNoFoodFound = true
            }
            completion?()
            return
        }
        
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🍽️ Sending category to backend:", trimmedCategory)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "category=\(trimmedCategory)"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async {
                    if forChat {
                        self.chatCategoryFoods = []
                        self.chatNoFoodFound = true
                    }
                    completion?()
                }
                return
            }
            
            print("🧾 Raw backend response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            if let decoded = try? JSONDecoder().decode([MenuItem].self, from: data), !decoded.isEmpty {
                DispatchQueue.main.async {
                    self.categoryFoods = decoded
                    if forChat {
                        self.chatCategoryFoods = decoded
                        self.chatNoFoodFound = false
                    }
                    completion?()
                }
            } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], json["message"] != nil {
                DispatchQueue.main.async {
                    if forChat {
                        self.chatCategoryFoods = []
                        self.chatNoFoodFound = true
                    }
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    if forChat {
                        self.chatCategoryFoods = []
                        self.chatNoFoodFound = true
                    }
                    completion?()
                }
            }
        }.resume()
    }
    
    func handleSuggestFood() {
        conversation.append((role: "user", text: "Suggest Food"))
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isTyping = false
            self.conversation.append((role: "ai", text: "Please select a category:"))
            self.chatSelectingCategory = true
            self.chatSelectingFood = false
        }
    }
    
    func handleSelectCategoryInChat(_ category: String) {
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        conversation.append((role: "user", text: trimmedCategory))
        isTyping = false
        chatSelectingCategory = false
        chatSelectingFood = false
        chatFoodLoading = true
        chatNoFoodFound = false
        conversation.append((role: "ai", text: "Fetching food items..."))
        
        fetchFoods(for: trimmedCategory, forChat: true) {
            self.chatFoodLoading = false
            self.chatSelectedCategory = trimmedCategory
            
            // Remove the last "Fetching food items..." message
            if let idx = self.conversation.lastIndex(where: { $0.role == "ai" && $0.text == "Fetching food items..." }) {
                self.conversation.remove(at: idx)
            }
            
            if self.chatCategoryFoods.isEmpty && self.chatNoFoodFound {
                self.conversation.append((role: "ai", text: "No food items could be found for \(trimmedCategory)."))
                self.chatSelectingFood = false
            } else {
                self.conversation.append((role: "ai", text: "Here are some \(trimmedCategory) items:"))
                self.chatSelectingFood = true
            }
        }
    }
    
    func handleSelectFoodInChat(_ item: MenuItem) {
        conversation.append((role: "user", text: item.name))
        chatSelectingFood = false
        print("🍽️ Navigate to \(item.name) page")
    }
}

// Rename the enum to avoid redeclaration/ambiguity
enum FAQCategoryPage: Hashable {
    case snack, breakfast, veg, nonveg
}

struct FAQChatPage: View {
    let userName: String
    let phoneNumber: String
    @StateObject private var vm = FAQViewModel()
    @State private var selectedCategoryPage: FAQCategoryPage?
    @State private var selectedFood: MenuItem?
    @State private var showRequestPopup = false
    @State private var requestQuestion = ""
    @State private var requestSending = false
    @State private var requestSent = false
    @State private var requestError = ""
    @State private var showFAQSheet = false
    // Add refresh state
    @State private var chatRefreshTrigger = false
    // Restore Home navigation state
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    // Remove the default back button
                    Spacer()
                    Text("\(vm.getGreeting()), \(userName)!")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                    // FAQ notification icon
                    Button(action: {
                        vm.fetchMyFAQs(phoneNumber: phoneNumber)
                        showFAQSheet = true
                    }) {
                        Image("chat")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.orange)
                    }
                    // --- Add refresh icon for chat ---
                    Button(action: {
                        vm.conversation.removeAll()
                        vm.input = ""
                        // Optionally, reset chat-related states
                        vm.isTyping = false
                        vm.chatSelectingCategory = false
                        vm.chatSelectingFood = false
                        vm.chatCategoryFoods = []
                        vm.chatSelectedCategory = nil
                        vm.chatFoodLoading = false
                        vm.chatNoFoodFound = false
                        chatRefreshTrigger.toggle()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(.leading, 8)
                    }
                }
                .sheet(isPresented: $showFAQSheet) {
                    NavigationView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Asked Questions")
                                .font(.title2)
                                .bold()
                                .padding(.bottom, 5)

                            if vm.userFAQs.isEmpty {
                                Text("❌ No questions found.")
                                    .foregroundColor(.gray)
                            } else {
                                ScrollView {
                                    ForEach(vm.userFAQs) { faq in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("📌 Q: \(faq.question)")
                                                .font(.headline)
                                            Text("💬 A: \(faq.answer ?? "No answer yet.")")
                                                .foregroundColor(.gray)
                                            Text("🕒 \(faq.created_at)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .navigationBarTitle("FAQ Notification", displayMode: .inline)
                        .navigationBarItems(trailing: Button("Close") {
                            showFAQSheet = false
                        })
                    }
                }



                Text(vm.weather)
                    .foregroundColor(.gray)
                    .font(.subheadline)

                if let offerMsg = vm.offerMsg {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "flame.fill").foregroundColor(.red)
                            Text(offerMsg).foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                }

                Spacer().frame(height: 50)

                ScrollView {
                    if vm.conversation.isEmpty {
                        VStack {
                            Image("man (1)")
                                .resizable()
                                .frame(width: 100, height: 100)
                            Text("FoodHub")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Text("Crave it. Click it. Eat it.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        ForEach(Array(vm.conversation.enumerated()), id: \.offset) { idx, msg in
                            HStack {
                                if msg.role == "ai" {
                                    Image("man (1)")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                }
                                Text(msg.text)
                                    .padding()
                                    .background(msg.role == "user" ? Color.blue.opacity(0.7) : Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                if msg.role == "user" {
                                    Image("user")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: msg.role == "user" ? .trailing : .leading)
                            .padding(.vertical, 2)

                            // Show food items inline only after the "Here are some ..." message
                            if msg.role == "ai",
                               msg.text.hasPrefix("Here are some"),
                               idx == vm.conversation.count - 1,
                               vm.chatSelectingFood,
                               !vm.chatCategoryFoods.isEmpty {

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(vm.chatCategoryFoods) { item in
                                            Button(action: {
                                                let cat = (vm.chatSelectedCategory ?? "").lowercased()
                                                // Set selectedCategoryPage using the new enum
                                                if cat == "snack" {
                                                    selectedCategoryPage = .snack
                                                } else if cat == "breakfast" {
                                                    selectedCategoryPage = .breakfast
                                                } else if cat == "veg" {
                                                    selectedCategoryPage = .veg
                                                } else if cat == "non-veg" || cat == "nonveg" || cat == "non_veg" {
                                                    selectedCategoryPage = .nonveg
                                                }
                                                vm.handleSelectFoodInChat(item)
                                            }) {
                                                VStack {
                                                    if let imageUrl = item.image_url, let url = URL(string: imageUrl) {
                                                        AsyncImage(url: url) { phase in
                                                            if let image = phase.image {
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                            } else if phase.error != nil {
                                                                Color.red
                                                            } else {
                                                                ProgressView()
                                                            }
                                                        }
                                                        .frame(width: 48, height: 48)
                                                        .clipShape(Circle())
                                                    } else {
                                                        Color.gray
                                                            .frame(width: 48, height: 48)
                                                            .clipShape(Circle())
                                                    }

                                                    Text(item.name)
                                                        .foregroundColor(.white)
                                                        .font(.caption2)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }


                            // --- RESTORE: Show categories inline after "Please select a category:" message ---
                            if msg.role == "ai",
                               msg.text == "Please select a category:",
                               idx == vm.conversation.count - 1,
                               vm.chatSelectingCategory {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(vm.chatCategories, id: \.self) { cat in
                                            Button(action: {
                                                vm.handleSelectCategoryInChat(cat)
                                            }) {
                                                Text(cat)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 10)
                                                    .background(Color.purple)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            // --- END RESTORE ---
                        }
                        if vm.isTyping {
                            Text("Cooking🍳...").foregroundColor(.white.opacity(0.7))
                        }
                        if vm.chatFoodLoading {
                            Text("Fetching food items...").foregroundColor(.white.opacity(0.7))
                        }
                    }
                }

                Text("🍳 What’s Cooking? Ask Away")
                    .foregroundColor(.white)
                    .padding(.top, 8)

                // --- Restore FAQ suggestion buttons here ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // Suggest Food button first
                        Button(action: {
                            vm.handleSuggestFood()
                        }) {
                            Label("Suggest Food", systemImage: "fork.knife")
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(20)
                                .foregroundColor(.white)
                        }
                        ForEach(vm.faqs) { faq in
                            Button(action: {
                                vm.input = faq.question
                            }) {
                                Text(faq.question)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // --- Search box with "+" button ---
                HStack {
                    TextField("Type a message...", text: $vm.input)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                    Button(action: {
                        let value = vm.input.trimmingCharacters(in: .whitespaces)
                        if !value.isEmpty {
                            vm.handleQuestion(value)
                            vm.input = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                    // --- "+" button for request ---
                    Button(action: {
                        showRequestPopup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                .padding(.vertical, 8)

                // Do NOT display categories here (below search box)
                if let selectedCategory = vm.selectedCategory {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍽️ \(selectedCategory) Items")
                            .foregroundColor(.white)
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.categoryFoods) { item in
                                    Button(action: {
                                        print("Navigate to \(item.name) page")
                                    }) {
                                        VStack {
                                            if let imageUrl = item.image_url,
                                               let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/\(imageUrl)") {
                                                AsyncImage(url: url) { phase in
                                                    if let image = phase.image {
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } else if phase.error != nil {
                                                        Color.red
                                                    } else {
                                                        ProgressView()
                                                    }
                                                }
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                            } else {
                                                Color.gray
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(Circle())
                                            }

                                            Text(item.name)
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // NavigationLinks for each category (hidden)
               
               
            }
            .padding()
            .background(Color(red: 18/255, green: 23/255, blue: 42/255))
            .ignoresSafeArea(.keyboard)
            // --- Fix: Only pass .environmentObject to Home and category pages, not Welcome ---
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(userName: userName, phoneNumber: phoneNumber)
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
            }
            .navigationDestination(item: $selectedCategoryPage) { page in
                categoryDestinationView(for: page)
            }

            // --- Request Popup Sheet ---
            .overlay(
                Group {
                    if showRequestPopup {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            HStack {
                                Text("Request a FAQ")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showRequestPopup = false }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                }
                            }
                            .padding(.bottom, 8)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Question")
                                    .foregroundColor(.white)
                                TextField("Type your question...", text: $requestQuestion)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 8)
                            if !requestError.isEmpty {
                                Text(requestError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            if requestSent {
                                Text("Request sent! We'll get back to you soon.")
                                    .foregroundColor(.green)
                                    .font(.body)
                            }
                            Button(action: {
                                if requestQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    requestError = "Please enter your question."
                                    return
                                }
                                requestError = ""
                                requestSending = true
                                sendFAQRequest()
                            }) {
                                HStack {
                                    if requestSending {
                                        ProgressView()
                                    }
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Request")
                                }
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(requestSending || requestSent)
                        }
                        .padding()
                        .background(Color(red: 30/255, green: 30/255, blue: 40/255))
                        .cornerRadius(20)
                        .padding(.horizontal, 32)
                    }
                }
            )
        }
    }

    // --- Add function to send FAQ request ---
    func sendFAQRequest() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/user_request.php") else {
            requestError = "Invalid server URL."
            requestSending = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = [
            "user_name": userName,
            "phone_number": phoneNumber,
            "question": requestQuestion
        ]
        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                requestSending = false
                if let error = error {
                    requestError = "Failed: \(error.localizedDescription)"
                    return
                }
                guard let data = data, let str = String(data: data, encoding: .utf8) else {
                    requestError = "No response from server."
                    return
                }
                if str.lowercased().contains("success") {
                    requestSent = true
                    requestQuestion = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showRequestPopup = false
                        requestSent = false
                    }
                } else {
                    requestError = "Failed to send request."
                }
            }
        }.resume()
    }

    func categoryForFood(_ item: MenuItem) -> String {

        return vm.chatSelectedCategory ?? ""
    }
    
    // --- Move this inside FAQChatPage ---
    @ViewBuilder
    private func categoryDestinationView(for page: FAQCategoryPage) -> some View {
        switch page {
        case .snack:
            SnacksPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(ShoppingCartModel())
                .environmentObject(FavoriteModel())
        case .breakfast:
            BreakfastPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(ShoppingCartModel())
                .environmentObject(FavoriteModel())
        case .veg:
            VegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(ShoppingCartModel())
                .environmentObject(FavoriteModel())
        case .nonveg:
            NonVegPage(userName: userName, phoneNumber: phoneNumber)
                .environmentObject(ShoppingCartModel())
                .environmentObject(FavoriteModel())
        }
    }
}


struct FAQChatPage_Previews: PreviewProvider {
    static var previews: some View {
        FAQChatPage(userName: "User", phoneNumber: "1234567890")
            .preferredColorScheme(.dark)
    }
}

