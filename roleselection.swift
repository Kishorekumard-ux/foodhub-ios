import SwiftUI

struct RoleSelectionView: View {
    @State private var navigateToLogin = false
    @State private var selectedRole = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo
                Image("page")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)

                // App Name
                Text("FoodHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose your role to continue")
                    .font(.headline)
                    .foregroundColor(.gray)

                // Role Selection
                HStack(spacing: 50) {
                    VStack {
                        Button(action: {
                            selectedRole = "user"
                            navigateToLogin = true
                        }) {
                            Image("user") // replace with your asset name
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                        Text("User")
                            .font(.headline)
                    }

                    VStack {
                        Button(action: {
                            selectedRole = "admin"
                            navigateToLogin = true
                        }) {
                            Image("user") // replace with your asset name
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                        Text("Admin")
                            .font(.headline)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    RoleSelectionView()
}
