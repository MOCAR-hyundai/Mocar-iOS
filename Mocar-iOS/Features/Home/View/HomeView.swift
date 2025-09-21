//
//  HomeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

let brandData: [Brand] = [
    Brand(name: "Ferrari", logo: "ferrari"),
    Brand(name: "Tesla", logo: "tesla"),
    Brand(name: "BMW", logo: "BMW"),
    Brand(name: "Kia", logo: "kia"),
    Brand(name: "Hyundal", logo: "hyundai"),
    Brand(name:"Audi",logo:"audi")
    
]

struct Brand : Identifiable {
    var id = UUID()
    var name: String
    var logo: String
}



struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    let listings: [Listing] = Listing.listingData
    
    var body: some View {
        NavigationStack{
            VStack {
                TopBar(style: .home)
                HStack{
                    //검색 창
                    ZStack(alignment: .leading){
                        Image("Search")
                            .padding(.leading,15)
                        TextField("Search", text: .constant(""))
                            .padding(.leading, 30)
                            .padding()
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    //검색 필터 버튼
                    Button(action:{
                        
                    }){
                        Image("iconfilter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // 아이콘 크기
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
                }
                .padding(.bottom,16)
                
                ScrollView(showsIndicators: false){
                    //찜한 목록
                    VStack(alignment: .leading, spacing: 8){
                        Text("찜한 목록")
                            .font(.headline)
                        Text("Available")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        //리스트
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 16) {
                                ForEach(homeViewModel.favorites,
                                        id: \.id) { listing in
                                    NavigationLink(destination: ListingDetailView(listingId: listing.id)) {
                                            FavoriteCardView(
                                                listing: listing,
                                                onToggleFavorite:{
                                                    homeViewModel.toggleFavorite(listing)
                                                }
                                            )
                                    }
                                     .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.bottom,16)
                    
                    //브랜드 스크롤
                    VStack(alignment: .leading, spacing: 8){
                        Text("Brands")
                            .font(.headline)
                            .padding(.bottom,8)
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                ForEach(brandData) { brand in
                                    BrandIconView(
                                        brand: brand,
                                        isSelected: homeViewModel.selectedBrand == brand.name,   // 선택 여부
                                        onSelect: {
                                            homeViewModel.selectBrand(brand)
                                            print("\(brand.name) selected")
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.bottom,16)
                        //브랜드 필터링 리스트
                        LazyVGrid(columns: [
                            GridItem(.flexible()), // 첫 번째 열
                            GridItem(.flexible())  // 두 번째 열
                        ], spacing: 16) {
                            ForEach(homeViewModel.filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listingId: listing.id)){
                                        ListingCardView(
                                            listing: listing,
                                            isFavorite: homeViewModel.favorites.contains { $0.id == listing.id },
                                            onToggleFavorite:{
                                                homeViewModel.toggleFavorite(listing)
                                            }
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
            }
            .padding()
            .background(Color.backgroundGray100)
        }
        .navigationBarHidden(true)
        .background(Color.backgroundGray100)
        
    }
   
}


#Preview{
    HomeView()
}
