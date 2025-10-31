import SwiftUI

struct AdminPage: View {
    let adminName: String
    let adminPhoneNumber: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image
                Image("user")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 40)

                // Title
                Text("Admin Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                // Admin Name
                Text("Welcome, \(adminName)")
                    .font(.headline)
                    .foregroundColor(.black)

                Spacer().frame(height: 30)

                // Buttons with NavigationLinks
                VStack(spacing: 20) {
                    NavigationLink(destination: AdminDashboardPage()) {
                        Text("View Fooditems")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: DiscountPage()) {
                        Text("Add Discount")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: MyOrderPage()) {
                        Text("View Orders")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: AdminFAQPage()) {
                        Text("User query")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: AdminAccountView(adminName: adminName, adminPhone: adminPhoneNumber)) {
                        Text("Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: LoginView()) {
                        Text("Signout")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview {
    AdminPage(adminName: "Admin", adminPhoneNumber: "1234567890")
}


