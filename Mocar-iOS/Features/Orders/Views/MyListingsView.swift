//
//  MyListingsView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct MyListingsView: View {
    let currentUserId: String
    
    @StateObject private var vm = MyListingsViewModel()
    @ObservedObject var favoritesViewModel: FavoritesViewModel   // 외부에서 주입
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack {
            TopBar(style: .Mylistings(title: "나의 등록 매물"))
                .padding(.bottom)
                .background(Color.backgroundGray100)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {

                    ForEach(vm.listings) { item in
                        NavigationLink(
                            destination: ListingDetailView(
                                listingId: item.id ?? "",             // 또는 Listing 자체를 전달하도록 뷰를 바꿀 수 있음
                                favoritesViewModel: favoritesViewModel
                            )
                        ) {
                            MyListingsCardView(
                                listing: item,
                                isFavorite: favoritesViewModel.isFavorite(item),
                                onToggleFavorite: {
                                    favoritesViewModel.toggleFavorite(item)
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                }
                .padding()
            }
            .onAppear {
                vm.fetchMyListings(userId: currentUserId)
            }
        }
    }
}

#Preview {
//    MyListingsView()
}
