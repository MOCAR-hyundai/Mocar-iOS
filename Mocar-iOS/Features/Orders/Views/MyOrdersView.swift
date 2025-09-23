//
//  MyOrdersView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct MyOrdersView: View {
    let currentUserId: String
    @StateObject private var vm = MyOrdersViewModel()
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
//        NavigationStack {
            VStack {
                TopBar(style: .Mylistings(title: "나의 구입 매물"))
                    .padding(.bottom)
                    .background(Color.backgroundGray100)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
//                        ForEach(vm.myOrders, id: \.listing.id) { item in
//                            NavigationLink(
//                                destination: ListingDetailView(
//                                    listingId: item.listing.id ?? "",
//                                    favoritesViewModel: favoritesViewModel
//                                )
//                            ) {
//                                OrdersCardView(
//                                    order: item.order,
//                                    listing: item.listing,
//                                    isFavorite: favoritesViewModel.isFavorite(item.listing),
//                                    onToggleFavorite: {
//                                        favoritesViewModel.toggleFavorite(item.listing)
//                                    }
//                                )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }

                        ForEach(vm.myOrders) { item in
                            NavigationLink(
                                destination: ListingDetailView(
                                    service: ListingServiceImpl(repository: ListingRepository(),
                                        userStore: UserStore()
                                    ),
                                    listingId: item.listing.id ?? ""
                                )
                            ) {
                                OrdersCardView(
                                    order: item.order,            // ✅ Order도 같이 전달
                                    listing: item.listing,
                                    isFavorite: favoritesViewModel.isFavorite(item.listing),
                                    onToggleFavorite: {
                                        Task { await favoritesViewModel.toggleFavorite(item.listing) }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .onAppear {
                    vm.fetchMyOrders(for: currentUserId)
                }
            }
//        }
    }
}

#Preview {
//    MyOrdersView()
}
