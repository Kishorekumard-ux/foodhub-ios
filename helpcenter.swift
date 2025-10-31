// HelpCenterPage.swift
import SwiftUI

struct HelpCenterPage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                // Circular Avatar with Image
                Image("page")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .background(Circle().fill(Color.gray.opacity(0.2)))

                // Hotel Name
                Text("FoodHub")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                // Address
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                    Text("123, Gandhi road, Kanchipuram, TamilNadu")
                        .font(.system(size: 16))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                // Phone
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text("91+ 6878908765")
                        .font(.system(size: 16))
                }

                // Email
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("contact@FoodHub.com")
                        .font(.system(size: 16))
                }

                // Help Instructions
                Text("If you have any issues or questions, feel free to contact us using the details above. We are here to help you!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Call Support Button
                Button(action: {
                    // Add call action
                }) {
                    HStack {
                        Image(systemName: "phone")
                        Text("Call Support")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
            .navigationBarTitle("Help Center", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // Handle back action here
            }) {
                Image("back")
                    .resizable()
                    .frame(width: 24, height: 24)
            })
        }
    }
}

struct HelpCenterPage_Previews: PreviewProvider {
    static var previews: some View {
        HelpCenterPage()
    }
}


#Preview {
    HelpCenterPage()
}
