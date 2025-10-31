import SwiftUI
import PhotosUI

struct UserFeedback: Identifiable, Codable {
    let id: Int
    let userName: String
    let foodName: String
    let rating: Int
    let feedback: String
    let imageUrl: String
    let date: Date
}

struct UserFeedbackView: View {
    @State private var feedbacks: [UserFeedback] = []
    @State private var searchText = ""
    @State private var filter = "Newest"
    @State private var showingAddFeedback = false
    @State private var isLoading = false
    @State private var fetchError: String?
    let userName: String

    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Button(action: {
                        filter = (filter == "Newest") ? "Oldest" : "Newest"
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    Button(action: {
                        fetchFeedbacks()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()

                if isLoading {
                    ProgressView("Loading feedbacks...")
                        .padding()
                } else if let error = fetchError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        fetchFeedbacks()
                    }
                } else if filteredFeedbacks.isEmpty {
                    Text("No feedbacks found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredFeedbacks) { feedback in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(feedback.userName).font(.headline)
                                Spacer()
                                Text(feedback.foodName).bold()
                            }
                            HStack {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < feedback.rating ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                            Text(feedback.feedback)
                            if !feedback.imageUrl.isEmpty, let url = URL(string: feedback.imageUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 150)
                                            .clipped()
                                    } else if phase.error != nil {
                                        Color.red.frame(height: 150)
                                    } else {
                                        Color.gray.frame(height: 150)
                                    }
                                }
                            }
                            Text("\(feedback.date, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Button("Add Feedback") {
                    showingAddFeedback = true
                }
                .padding()
                .sheet(isPresented: $showingAddFeedback) {
                    AddFeedbackView(userName: userName) {
                        fetchFeedbacks()
                    }
                }
            }
            .navigationTitle("Feedback")
            .toolbar {
                Button(action: fetchFeedbacks) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .onAppear(perform: fetchFeedbacks)
        }
    }

    var filteredFeedbacks: [UserFeedback] {
        var filtered = feedbacks
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.foodName.lowercased().contains(searchText.lowercased()) ||
                $0.feedback.lowercased().contains(searchText.lowercased()) ||
                $0.userName.lowercased().contains(searchText.lowercased())
            }
        }
        if filter == "Newest" {
            filtered.sort { $0.date > $1.date }
        } else {
            filtered.sort { $0.date < $1.date }
        }
        return filtered
    }

    func fetchFeedbacks() {
        isLoading = true
        fetchError = nil

        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/fetch_feedback.php") else {
            fetchError = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        if !searchText.isEmpty {
            request.httpMethod = "POST"
            let params: [String: String]
            // If searchText matches a username, send as userName, else as foodName
            if searchText.lowercased() == userName.lowercased() {
                params = ["userName": searchText]
            } else {
                params = ["foodName": searchText]
            }
            request.httpBody = params
                .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                .joined(separator: "&")
                .data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    fetchError = "Network error: \(error.localizedDescription)"
                    print("❌ Network error: \(error)")
                    return
                }

                guard let data = data else {
                    fetchError = "No data received"
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let decoded = try decoder.decode([UserFeedback].self, from: data)
                    self.feedbacks = decoded
                } catch {
                    fetchError = "Failed to decode feedbacks"
                    print("❌ JSON decode error: \(error)")
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Raw JSON: \(raw)")
                    }
                }
            }
        }.resume()
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct AddFeedbackView: View {
    let userName: String
    var onSubmit: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var foodName = ""
    @State private var feedbackText = ""
    @State private var rating = 0
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationView {
            Form {
                TextField("Food Name", text: $foodName)
                TextField("Your Feedback", text: $feedbackText)

                Picker("Rating", selection: $rating) {
                    ForEach(1...5, id: \.self) { i in
                        Text("\(i) Stars").tag(i)
                    }
                }

                PhotosPicker("Pick Image", selection: $selectedImage, matching: .images)

                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }

                Button("Submit") {
                    submitFeedback()
                }
            }
            .navigationTitle("Add Feedback")
            // Update deprecated onChange to use zero-parameter closure
            .onChange(of: selectedImage) {
                Task {
                    if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    func submitFeedback() {
        guard let imageData = imageData else { return }
        var request = URLRequest(url: URL(string: "http://14.139.187.229:8081/mca/foodhub/submit_feedback.php")!)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func append(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        append("userName", userName)
        append("foodName", foodName)
        append("feedback", feedbackText)
        append("rating", String(rating))

        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                } else if let data = data, let responseText = String(data: data, encoding: .utf8) {
                    print("Server response: \(responseText)")
                    if responseText.contains("Success") {
                        onSubmit()
                        dismiss()
                    } else {
                        print("Upload failed: \(responseText)")
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    UserFeedbackView(userName: "Test User")
}




