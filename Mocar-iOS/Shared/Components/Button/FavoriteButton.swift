//
//  FavoriteButton.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import SwiftUI

struct FavoriteButton: View {
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    let listing: Listing
    
    var body: some View {
        Button(action: {
            favoritesViewModel.toggleFavorite(listing)
        }) {
            Image(systemName: favoritesViewModel.isFavorite(listing) ? "heart.fill" : "heart")
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
        }
        .padding(14)
    }
}


