import SwiftUI

struct DiscountPage: View {
    @State private var selectedCategory: String = ""
    @State private var discount: String = ""
    @State private var showMessage = false
    @State private var message = ""
    @State private var isSuccess = false

    let categories = ["snack", "Breakfast", "Veg", "Non-Veg"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Select Category", selection: $selectedCategory) {
                    Text("Select Category").tag("")
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                TextField("Discount (%)", text: $discount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                Button(action: {
                    updateDiscount()
                }) {
                    Text("Update Discount")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }

                if showMessage {
                    Text(message)
                        .foregroundColor(isSuccess ? .green : .red)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Set Category Discount")
        }
    }

    func updateDiscount() {
        guard !selectedCategory.isEmpty, !discount.isEmpty else {
            showMessage = true
            message = "Please select a category and enter a discount"
            isSuccess = false
            return
        }

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/update_discount.php") else {
            message = "Invalid URL"
            showMessage = true
            isSuccess = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = "category=\(selectedCategory)&discount=\(discount)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Network error: \(error.localizedDescription)"
                    self.isSuccess = false
                    self.showMessage = true
                    return
                }

                guard let data = data,
                      let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let status = responseJSON["status"] as? String else {
                    self.message = "Invalid server response"
                    self.isSuccess = false
                    self.showMessage = true
                    return
                }

                if status == "success" {
                    self.message = "Discount updated successfully"
                    self.isSuccess = true
                } else {
                    self.message = responseJSON["message"] as? String ?? "Update failed"
                    self.isSuccess = false
                }

                self.showMessage = true
            }
        }.resume()
    }
}


#Preview {
    DiscountPage()
}
