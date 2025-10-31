// AboutPage.swift
import SwiftUI

struct AboutPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Section
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.orange, .black]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 250)
                        .overlay(
                            Image("h1")
                                .resizable()
                                .scaledToFill()
                        )
                        .clipped()

                    Text("Welcome to FoodHub Hotel")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 2, y: 2)
                }

                // Overview
                CardView {
                    Text("At FoodHub Hotel, we provide an exceptional dining experience with the finest dishes prepared by expert chefs. Whether you are here for a casual meal or placing a bulk order for a large event, we guarantee quality and excellent service.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                }

                // Timeline
                VStack(alignment: .leading, spacing: 10) {
                    Text("Our Journey")
                        .font(.title2.bold())

                    TimelineItem(year: "2010", description: "FoodHub Hotel Established.", image: "h1", imagesForSlide: ["h1", "h2", "h3", "h4"])
                    TimelineItem(year: "2015", description: "Awarded Best Hospitality Service.", image: "s", imagesForSlide: [])
                    TimelineItem(year: "2020", description: "Launched Bulk Order Service.", image: "delivered", imagesForSlide: [])
                
                }
                .padding(.horizontal)

                // Chef
                CardView {
                    VStack {
                        Text("Meet Our Chef")
                            .font(.title2.bold())
                        Image("chef")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        Text("\"We use the best ingredients, prepared with care and served with love.\" - Chef [Mukesh]")
                            .font(.system(size: 18))
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                }

                // Testimonials
                VStack(alignment: .leading, spacing: 10) {
                    Text("What Our Customers Say")
                        .font(.title2.bold())
                    Testimonial(quote: "\"FoodHub Hotel provided the best food for our corporate event. Highly recommended!\"", customer: "Sarah, Corporate Client")
                    Testimonial(quote: "\"Amazing food quality and on-time delivery. The bulk order service was fantastic!\"", customer: "John, Event Organizer")
                }
                .padding(.horizontal)

                // CTA
                VStack(spacing: 16) {
                    Text("Order for Your Next Event")
                        .font(.title2.bold())
                    Text("Need to place a bulk order? Let us handle the food while you enjoy the event!")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)

                    Button(action: {
                        // Navigation action here
                    }) {
                        Text("Place a Bulk Order")
                            .font(.system(size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                }
                .padding(.horizontal)

                // Contact
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contact Us")
                        .font(.title2.bold())
                    ContactInfo(text: "Phone: +1 (123) 456-7890")
                    ContactInfo(text: "Email: info@foodhubhotel.com")
                    ContactInfo(text: "Address: 123 Main Street, City, Country")
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("About Us")
    }
}

struct CardView<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}

struct TimelineItem: View {
    let year: String
    let description: String
    let image: String
    let imagesForSlide: [String]?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)
                    .overlay(Text(year).font(.caption).bold().foregroundColor(.white))
                Text(description).font(.body.bold())
            }

            if let slides = imagesForSlide, !slides.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(slides, id: \ .self) { img in
                            Image(img)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            } else {
                Image(image)
                    .resizable()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct Testimonial: View {
    let quote: String
    let customer: String

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text(quote)
                    .italic()
                HStack {
                    Spacer()
                    Text("- \(customer)")
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct ContactInfo: View {
    let text: String
    var body: some View {
        Text(text).font(.system(size: 18))
    }
}

struct AboutPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutPage()
        }
    }
}

