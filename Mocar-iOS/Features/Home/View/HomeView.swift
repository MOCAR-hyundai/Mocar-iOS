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
                                    BrandsIconView(
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


struct FavoriteCardView: View{
    let listing: Listing
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image("hyundai")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 120)   // frame을 카드 width에 맞춤
                    .clipped()                        // 잘려서 여백 없애기

                Button(action: {
                    onToggleFavorite()
                }) {
                    Image(systemName: "heart.fill" )
                        .foregroundColor(.red)
                        .padding(0)
                }
            }
            CarInfoView(listing: listing)
            
        }
        .padding(24)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .background(Color.white)  // 카드 내부 색 지정
        .cornerRadius(12)

    }
}

struct ListingCardView: View{
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
            ZStack(alignment: .topTrailing){
                Image("hyundai")
                    .resizable()
                
                Button(action: {
                    onToggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                }
            }
            CarInfoView(listing: listing)
            
            
            
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .background(Color.white) 
        .cornerRadius(12)
        .frame(width: 170, height: 223)
        
    }
}

struct CarInfoView: View {
    let listing: Listing
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
      
            Text(listing.model)
                .fontWeight(.semibold)
                .foregroundColor(.textBlack100)
            HStack{
                Text("\(listing.mileage)Km")
                    .foregroundColor(.textGray100)
                Image("iconlocation")
                    .resizable()
                    .frame(width: 13, height: 15)
                Text(listing.region)
                    .foregroundColor(.textGray100)
            }
            Text("\(listing.price)만원")
                .padding(.top,4)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.keyColorBlue)
            
        }
        .padding(10)
    }
}



struct BrandsIconView: View {
    let brand: Brand
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action:{
            onSelect()
        }){
            VStack{
                Image(brand.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(15) // 이미지 주변에 여백 → 원 안에 들어가게
                    .background(
                        Circle()
                            .fill(Color.white) // 흰 배경 원
                            .overlay(
                                Circle().stroke(isSelected ? Color.keyColorBlue : Color.borderGray, lineWidth: 1)
                            )
                            .frame(width: 65, height: 65)
                    )
                Text(brand.name)
                    .foregroundColor(Color.textGray200)
            }
        }
    }
}

#Preview{
    HomeView()
}
