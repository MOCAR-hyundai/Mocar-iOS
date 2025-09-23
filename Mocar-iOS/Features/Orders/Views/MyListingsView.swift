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
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: String? = nil
    
    // ✅ 선택한 카테고리에 따라 listings 필터링
      var filteredListings: [Listing] {
          guard let selectedCategory = selectedCategory else {
              return vm.listings
          }
          
          switch selectedCategory {
          case "onSale":
              return vm.listings.filter { $0.status == .onSale }
          case "reserved":
              return vm.listings.filter { $0.status == .reserved }
          case "soldOut":
              return vm.listings.filter { $0.status == .soldOut }
          default: // "nill" → 전체
              return vm.listings
          }
      }
    
    var categoryTitle: String {
        switch selectedCategory {
        case "onSale":
            return "판매중"
        case "reserved":
            return "예약중"
        case "soldOut":
            return "판매 완료"
        default:
            return "전체"
        }
    }
    
    var body: some View {
        VStack (spacing: 0){
            TopBar(style: .Mylistings(title: "나의 등록 매물"))
                .padding(.bottom)
                .background(Color.backgroundGray100)
            
            // MARK: - 카테고리 바
            HStack(spacing: 16) {
                
                Menu {
                    Button("전체") { selectedCategory = "nill" }
                    Button("판매중") { selectedCategory = "onSale" }
                    Button("예약중") { selectedCategory = "reserved" }
                    Button("판매 완료") { selectedCategory = "soldOut" }
                } label: {
                    HStack(spacing: 5) {
                        Text(categoryTitle)
//                        Text("판매 상태")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                            .font(.system(size: 10))
                    }
                }
                
                Spacer()
              
            }
            .padding()
            .padding(.leading,3)
            
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {

//                    ForEach(vm.listings) { item in
                    // ✅ 필터링된 배열 사용
                    ForEach(filteredListings) { item in
                        NavigationLink(
                            destination: ListingDetailView(
                                service: ListingServiceImpl(repository: ListingRepository(),
                                    userStore: UserStore()
                                ),
                                            listingId: item.id ?? ""
                            )
                        ) {
                            MyListingsCardView(
                                listing: item,
                                isFavorite: favoritesViewModel.isFavorite(item),
                                onToggleFavorite: {
                                    Task { await favoritesViewModel.toggleFavorite(item) }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                }
                .padding()
            }
            .background(Color.backgroundGray100)
            .onAppear {
                vm.fetchMyListings(userId: currentUserId)
            }
        }
        .background(Color.backgroundGray100)
    }
}
