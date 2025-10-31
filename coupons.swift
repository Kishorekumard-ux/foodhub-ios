import SwiftUI

// MARK: - Coupon Model
struct Coupon: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let code: String
    let imageName: String
}

// MARK: - Coupons Page
struct CouponsPage: View {
    let coupons: [Coupon] = [
        Coupon(title: "20% Off", description: "Valid on orders above ₹500", code: "20PERCENT", imageName: "50%"),
        Coupon(title: "₹100 Cashback", description: "On orders above ₹1000", code: "CASHBACK100", imageName: "cashback"),
        Coupon(title: "10% Off", description: "Valid for first-time users", code: "FIRST10", imageName: "coupon"),
        Coupon(title: "20% Off", description: "Order more and Save more", code: "BULK20", imageName: "coupon"),
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Banner Image
                Image("coupon1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .padding(.bottom, 5)

                // Coupons List
                List(coupons) { coupon in
                    CouponCard(coupon: coupon)
                        .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Coupons", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // Action handled automatically in NavigationStack
            }) {
                Image("back")
                    .resizable()
                    .frame(width: 24, height: 24)
            })
        }
    }
}

// MARK: - Coupon Card View
struct CouponCard: View {
    let coupon: Coupon
    @State private var showCopied = false

    var body: some View {
        HStack(alignment: .center) {
            Image(coupon.imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .padding(.leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(coupon.title)
                    .font(.headline)
                Text(coupon.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()

            Button(action: {
                UIPasteboard.general.string = coupon.code
                showCopied = true
            }) {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.blue)
            }
            .padding()
            .alert(isPresented: $showCopied) {
                Alert(title: Text("Copied"), message: Text("Coupon Code '\(coupon.code)' Copied!"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct CouponsPage_Previews: PreviewProvider {
    static var previews: some View {
        CouponsPage()
    }
}

