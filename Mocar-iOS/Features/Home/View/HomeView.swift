//
//  HomeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var userSession = UserSession()
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack{
            VStack {
                TopBar(
                    style: .home(isLoggedIn: userSession.user != nil),
                    onLoginTap:{showLogin = true}
                )
                NavigationLink(
                    destination: LoginView()
                        .navigationBarHidden(true)       // 기본 네비게이션 바 숨김
                        .navigationBarBackButtonHidden(true),
                    isActive: $showLogin
                ) {
                    EmptyView()
                }
                
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
                .padding(.vertical,16)
                
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
                                ForEach(homeViewModel.favorites) { favorite in
                                    if let listing = homeViewModel.listings.first(where: {$0.id == favorite.listingId}){
                                        NavigationLink(destination: ListingDetailView(listingId: favorite.listingId)) {
                                                FavoriteCardView(
                                                    listing: listing,
                                                    isFavorite: homeViewModel.isFavorite(listing),
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
                    .padding(.bottom,16)
                    
                    //브랜드 스크롤
                    VStack(alignment: .leading, spacing: 8){
                        Text("Brands")
                            .font(.headline)
                            .padding(.bottom,8)
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 20) {
                                ForEach(homeViewModel.brands, id: \.self) { brand in
                                    let logo = brandLogoMap[brand] ?? "이미지없음icon"
                                    BrandIconView(
                                        brand: Brand(name: brand, logo: logo),
                                        isSelected: homeViewModel.selectedBrand == brand,  // 선택 여부
                                        onSelect: {
                                            homeViewModel.selectBrand(brand)
                                            print("\(brand) selected")
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
                            ForEach(homeViewModel.filteredListings.compactMap{$0.id}, id: \.self) { id in
                                if let listing = homeViewModel.filteredListings.first(where: {$0.id == id}){
                                    NavigationLink(destination: ListingDetailView(listingId: id)){
                                            ListingCardView(
                                                listing: listing,
                                                isFavorite: homeViewModel.isFavorite(listing),
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
                
            }
            .padding()
            .background(Color.backgroundGray100)
        }
        .navigationBarHidden(true)
        .background(Color.backgroundGray100)
        
    }
   
}

