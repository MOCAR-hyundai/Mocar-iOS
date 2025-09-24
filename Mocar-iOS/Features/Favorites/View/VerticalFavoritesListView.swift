//
//  VerticalFavoritesListView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct VerticalFavoritesListView: View {
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    
    var body: some View {
        TopBar(style: .Mylistings(title: "나의 찜 매물"))
            .padding(.bottom)
            .background(Color.backgroundGray100)
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
                    ForEach(favoritesVM.favoriteListings,id: \.safeId) { listing in
                        NavigationLink(
                            destination: ListingDetailView(
                                service: ListingServiceImpl(repository: ListingRepository(),
                                    userStore: UserStore()
                                ),
                                listingId: listing.id ?? ""
                            )
                        ){
                            VerticalListingCardView(
                                listing: listing,
                                isFavorite: favoritesVM.isFavorite(listing),
                                onToggleFavorite: {
                                    Task { await favoritesVM.toggleFavorite(listing) }
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
