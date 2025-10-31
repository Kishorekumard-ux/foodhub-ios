//
//  HUBFOODApp.swift
//  HUBFOOD
//
//  Created by Mac-24 on 17/06/25.
//

import SwiftUI

@main
struct HUBFOODApp: App {
    // You can inject shared state objects here if needed (like cart or favorites)
    @StateObject private var cart = ShoppingCartModel()
    @StateObject private var favoriteModel = FavoriteModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(cart)
                    .environmentObject(favoriteModel)
            }
        }
    }
}

