import SwiftUI
import PhotosUI

struct FoodItem: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var price: Double
    var category: String
    var availability_time: String
    var stock_level: Int
    var image_url: String?
}

class DashboardViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var searchQuery = ""

    let baseURL = "http://localhost/foodhub"

    func fetchFoodItems() {
        isLoading = true
        guard let url = URL(string: "\(baseURL)/foodpage.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "search=\(searchQuery)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let data = data else { return }
                // Debug: print backend response
                print(String(data: data, encoding: .utf8) ?? "No data")
                if let rawArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let items: [FoodItem] = rawArray.compactMap { dict in
                        // Accept id as Int or String
                        let idValue = dict["id"]
                        let id: String
                        if let idInt = idValue as? Int {
                            id = String(idInt)
                        } else if let idStr = idValue as? String {
                            id = idStr
                        } else {
                            return nil
                        }
                        guard
                            let name = dict["name"] as? String,
                            let description = dict["description"] as? String,
                            let category = dict["category"] as? String,
                            let availability_time = dict["availability_time"] as? String
                        else { return nil }
                        // Accept price as Double, Int, or String
                        let priceValue = dict["price"]
                        let price: Double
                        if let p = priceValue as? Double {
                            price = p
                        } else if let p = priceValue as? Int {
                            price = Double(p)
                        } else if let p = priceValue as? String, let val = Double(p) {
                            price = val
                        } else {
                            price = 0
                        }
                        // Accept stock_level as Int or String
                        let stockValue = dict["stock_level"]
                        let stock_level: Int
                        if let s = stockValue as? Int {
                            stock_level = s
                        } else if let s = stockValue as? String, let val = Int(s) {
                            stock_level = val
                        } else {
                            stock_level = 0
                        }
                        // Accept image_url as String or nil
                        let image_url = dict["image_url"] as? String
                        return FoodItem(
                            id: id,
                            name: name,
                            description: description,
                            price: price,
                            category: category,
                            availability_time: availability_time,
                            stock_level: stock_level,
                            image_url: image_url
                        )
                    }
                    print("Fetched items count: \(items.count)") // Debug print
                    self.foodItems = items
                }
            }
        }.resume()
    }

    func addOrUpdateFoodItem(_ item: FoodItem, image: UIImage?, isUpdate: Bool, completion: @escaping () -> Void) {
        let endpoint = isUpdate ? "updatefood.php" : "addfood.php"
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func append(_ key: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        if isUpdate { append("id", item.id) }
        append("name", item.name)
        append("description", item.description)
        append("price", String(item.price))
        append("category", item.category)
        append("availability_time", item.availability_time)
        append("stock_level", String(item.stock_level))

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"food.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                self.fetchFoodItems()
                completion()
            }
        }.resume()
    }

    func deleteFoodItem(id: String) {
        guard let url = URL(string: "\(baseURL)/deletefood.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.fetchFoodItems()
            }
        }.resume()
    }
}

struct AdminDashboardPage: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var showAddEdit = false
    @State private var editingItem: FoodItem?
    @State private var editingImage: UIImage?

    @State private var itemToDeleteID: String?
    @State private var showDeleteAlert = false

    // Add state for deletion message
    @State private var deletionMessage: String = ""
    @State private var showDeletionMessage: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search for food...", text: $vm.searchQuery, onCommit: {
                        vm.fetchFoodItems()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: { vm.fetchFoodItems() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()

                if vm.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(vm.foodItems) { item in
                            FoodCard(foodItem: item,
                                     onEdit: {
                                         editingItem = item
                                         showAddEdit = true
                                     },
                                     onDelete: {
                                         itemToDeleteID = item.id
                                         showDeleteAlert = true
                                     })
                            // Add vertical padding and hide separator for spacing
                            .padding(.vertical, 8)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                Button(action: {
                    editingItem = nil
                    showAddEdit = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddEdit) {
                AddEditFoodDialog(
                    foodItem: editingItem,
                    onSubmit: { item, image in
                        vm.addOrUpdateFoodItem(item, image: image, isUpdate: item.id != "", completion: {
                            showAddEdit = false
                        })
                    }
                )
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Item"),
                    message: Text("Do you really want to delete this food item?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let id = itemToDeleteID,
                           let deletedItem = vm.foodItems.first(where: { $0.id == id }) {
                            vm.deleteFoodItem(id: id)
                            // Set deletion message and show it
                            deletionMessage = "\(deletedItem.name) deleted"
                            showDeletionMessage = true
                            // Hide message after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showDeletionMessage = false
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            // Show deletion message as overlay
            .overlay(
                Group {
                    if showDeletionMessage {
                        Text(deletionMessage)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }, alignment: .top
            )
            .onAppear {
                vm.fetchFoodItems()
            }
        }
    }
}
struct AddEditFoodDialog: View {
    @Environment(\.presentationMode) var presentationMode
    @State var foodItem: FoodItem?
    @State var name = ""
    @State var description = ""
    @State var price = ""
    @State var category = ""
    @State var availabilityTime = ""
    @State var stockLevel = ""
    @State var selectedImage: UIImage?
    @State var showImagePicker = false

    let onSubmit: (FoodItem, UIImage?) -> Void

    let categories = ["snack", "Breakfast", "Veg", "Non-Veg"]

    var body: some View {
        NavigationView {
            Form {
                Button("Upload Food Image") { showImagePicker = true }
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                TextField("Food Name", text: $name)
                TextField("Description", text: $description)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                Section {
                    TextField("Availability Time", text: $availabilityTime)
                    Text("Format: 6:00 AM - 10:00 PM")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                TextField("Stock Level", text: $stockLevel)
                    .keyboardType(.numberPad)
            }
            .navigationBarTitle(foodItem == nil ? "Add Food Item" : "Edit Food Item", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Submit") {
                    let item = FoodItem(
                        id: foodItem?.id ?? "",
                        name: name,
                        description: description,
                        price: Double(price) ?? 0,
                        category: category,
                        availability_time: availabilityTime,
                        stock_level: Int(stockLevel) ?? 0,
                        image_url: foodItem?.image_url
                    )
                    onSubmit(item, selectedImage)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                if let item = foodItem {
                    name = item.name
                    description = item.description
                    price = String(item.price)
                    category = item.category
                    availabilityTime = item.availability_time
                    stockLevel = String(item.stock_level)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

struct FoodCard: View {
    let foodItem: FoodItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: foodItem.image_url ?? "http://14.139.187.229:8081/mca/foodhub/assets/default_image.png")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(foodItem.name).font(.headline)
                Text(foodItem.description).font(.subheadline)
            }
            Spacer()

            // ✏️ Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain) // ✅ Prevents interference

            // 🗑 Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain) // ✅ Prevents interference
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle()) // Just to preserve layout tap zone
    }
}



// ImagePicker using PHPickerViewController
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Previews

struct AdminDashboardPage_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardPage()
    }
}

struct AddEditFoodDialog_Previews: PreviewProvider {
    static var previews: some View {
        AddEditFoodDialog(
            foodItem: FoodItem(
                id: "1",
                name: "Sample Food",
                description: "Tasty and delicious",
                price: 10.0,
                category: "Veg",
                availability_time: "10:00-14:00",
                stock_level: 20,
                image_url: nil
            ),
            onSubmit: { _, _ in }
        )
    }
}


#Preview {
    AdminDashboardPage()
}
