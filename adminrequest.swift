import SwiftUI
import Foundation

// MARK: - Model
struct RequestedFAQ: Identifiable, Codable {
    let id: Int
    let phone_number: String
    let question: String
    var answer: String?
    let created_at: String
}

// MARK: - ViewModel
class AdminFAQViewModel: ObservableObject {
    @Published var allFAQs: [RequestedFAQ] = []

    func fetchAllFAQs() {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/fetch_requested_faqs.php") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let faqs = try JSONDecoder().decode([RequestedFAQ].self, from: data)
                DispatchQueue.main.async {
                    self.allFAQs = faqs
                }
            } catch {
                print("❌ Error decoding:", error)
            }
        }.resume()
    }

    func submitAnswer(faqId: Int, answer: String) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/submit_answer.php") else { return }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"id\"\r\n\r\n")
        body.append("\(faqId)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"answer\"\r\n\r\n")
        body.append("\(answer)\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.fetchAllFAQs()
                }
            }
        }.resume()
    }

    func addNewFAQ(question: String, answer: String) {
        guard let url = URL(string: "http://14.139.187.229:8081/mca/foodhub/add_faq.php") else { return }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"question\"\r\n\r\n")
        body.append("\(question)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"answer\"\r\n\r\n")
        body.append("\(answer)\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.fetchAllFAQs()
                }
            }
        }.resume()
    }
}

// MARK: - Data extension for form-data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Main AdminFAQPage with Add FAQ Feature
struct AdminFAQPage: View {
    @StateObject private var vm = AdminFAQViewModel()
    @State private var answerInputs: [Int: String] = [:]
    @State private var repliedFAQs: Set<Int> = []
    @State private var replySuccess: [Int: Bool] = [:]
    @State private var showAddFAQ = false
    @State private var newQuestion = ""
    @State private var newAnswer = ""

    var body: some View {
        NavigationView {
            VStack {
                if vm.allFAQs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No FAQ requests yet.")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.allFAQs) { faq in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("📱 \(faq.phone_number)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("❓ \(faq.question)")
                                    .font(.headline)

                                if let answer = faq.answer, !answer.isEmpty || repliedFAQs.contains(faq.id) {
                                    let shownAnswer = faq.answer ?? answerInputs[faq.id] ?? ""
                                    Text("✅ Answer: \(shownAnswer)")
                                        .foregroundColor(.green)

                                    if replySuccess[faq.id] == true {
                                        Text("✅ Replied successfully")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }

                                    Button("Replied") {}
                                        .disabled(true)
                                        .buttonStyle(.bordered)
                                } else {
                                    TextField("Type your answer here...", text: Binding(
                                        get: { answerInputs[faq.id] ?? "" },
                                        set: { answerInputs[faq.id] = $0 }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("Send Answer") {
                                        let answer = answerInputs[faq.id] ?? ""
                                        if !answer.isEmpty {
                                            vm.submitAnswer(faqId: faq.id, answer: answer)
                                            repliedFAQs.insert(faq.id)
                                            replySuccess[faq.id] = true
                                            answerInputs[faq.id] = ""
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                replySuccess[faq.id] = false
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Answer FAQs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddFAQ = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFAQ) {
                NavigationStack {
                    Form {
                        Section(header: Text("Question")) {
                            TextField("Enter your question", text: $newQuestion)
                        }
                        Section(header: Text("Answer")) {
                            TextField("Enter the answer", text: $newAnswer)
                        }
                        Button("Submit FAQ") {
                            if !newQuestion.isEmpty && !newAnswer.isEmpty {
                                vm.addNewFAQ(question: newQuestion, answer: newAnswer)
                                showAddFAQ = false
                                newQuestion = ""
                                newAnswer = ""
                            }
                        }
                        .disabled(newQuestion.isEmpty || newAnswer.isEmpty)
                    }
                    .navigationTitle("Add FAQ")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddFAQ = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.fetchAllFAQs()
        }
    }
}


// MARK: - Preview
#Preview {
    AdminFAQPage()
}

