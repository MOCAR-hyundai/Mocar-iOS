//
//  VerticalFavoritesView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct VerticalFavoritesView: View {
    @StateObject private var favoritesViewModel : FavoritesViewModel
    
    init(favoritesViewModel: FavoritesViewModel = DIContainer.shared.favoritesVM) {
        _favoritesViewModel = StateObject(wrappedValue: favoritesViewModel)
    }
    
    var body: some View {
        TopBar(style: .list(title: "\(favoritesViewModel.favoritesCount)대"))
        ScrollView(showsIndicators: false){
            //찜한 목록
            VStack(alignment: .leading, spacing: 8){
                
                LazyVGrid(
                   columns: [
                       GridItem(.flexible(), spacing: 16),
                       GridItem(.flexible(), spacing: 16)
                   ],
                   spacing: 16
                ) {
                    ForEach(favoritesViewModel.favoriteListings,id: \.safeId) { listing in
                        NavigationLink(
                           destination: ListingDetailView(
                               listingId: listing.id ?? "",
                               favoritesViewModel: favoritesViewModel,
                               service: ListingServiceImpl(repository: ListingRepository())
                           )
                        ){
                            VerticalListingCardView(
                                listing: listing,
                                isFavorite: favoritesViewModel.isFavorite(listing),
                                onToggleFavorite: {
                                    favoritesViewModel.toggleFavorite(listing)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom,16)
           
        }
        .navigationBarBackButtonHidden(true)
    }
}
