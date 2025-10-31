import SwiftUI

struct ContentView: View {
    @State private var navigateToLogin = false
    @State private var navigateToHome = false

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("username") var storedUsername = ""
    @AppStorage("phoneNumber") var storedPhone = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: .white.opacity(0.6), radius: 10)
                    .overlay(
                        Image("page")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .padding(6)
                    )

                Text("FoodHub")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Text("Choose your preference")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                Text("WHAT'S YOUR FAVORITE FOOD?")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)

                Image("delivery")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)

                Spacer()

                Button(action: {
                    if isLoggedIn && !storedUsername.isEmpty && !storedPhone.isEmpty {
                        navigateToHome = true
                    } else {
                        navigateToLogin = true
                    }
                }) {
                    Text("Get Started")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(30)
                        .padding(.horizontal, 50)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)

            // Navigation destinations
            .navigationDestination(isPresented: $navigateToLogin) {
                RoleSelectionView()
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView(userName: storedUsername, phoneNumber: storedPhone)
                    .environmentObject(ShoppingCartModel())
                    .environmentObject(FavoriteModel())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ShoppingCartModel())
        .environmentObject(FavoriteModel())
}
