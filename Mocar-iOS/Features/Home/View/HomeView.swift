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
    Brand(name: "Kia", logo: "kia")
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
            TopBar(style: .home)

            VStack {
                HStack{
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
                
                ScrollView(){
                    //찜한 목록
                    VStack(alignment: .leading, spacing: 8){
                        Text("찜한 목록")
                            .font(.headline)
                        Text("Available")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 16) {
                                ForEach(listings) { listing in
                                    NavigationLink(destination: ListingDetailView(listingId: listing.id)) {
                                            FavoriteCardView(listing: listing, isFavorite: true)
                                        }
                                         .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.bottom,16)
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("Brands")
                            .font(.headline)
                            .padding(.bottom,8)
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 40) {
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
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()), // 첫 번째 열
                            GridItem(.flexible())  // 두 번째 열
                        ], spacing: 16) {
                            ForEach(homeViewModel.filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listingId: listing.id)){
                                        ListingCardView(listing: listing, isFavorite: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
            }
            .padding()
            .background(Color(hex: "#f8f8f8"))
        }
        .background(Color(hex: "#f8f8f8"))
    }
}


struct FavoriteCardView: View{
    let listing: Listing
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {   // spacing 0 → 4 정도 주면 자연스러움
            ZStack(alignment: .topTrailing) {
                Image("hyundai")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 120)   // frame을 카드 width에 맞춤
                    .clipped()                        // 잘려서 여백 없애기

                Button(action: {
                    print("하트 클릭")
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(0)
                }
            }

            Text(listing.model)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.top, 4)   // 제목 위쪽에만 padding

            HStack(spacing: 4) {
                Text("\(listing.mileage)Km")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
                Image("iconlocation")
                    .resizable()
                    .frame(width: 14, height: 17)
                Text(listing.region)
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
            }

            Text("\(listing.price)만원")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "#3058EF"))
                .padding(.top, 2)
        }
        .padding(24)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .background(Color.white)  // 카드 내부 색 지정 (투명 여백 확인용)
        .cornerRadius(12)

    }
}

struct ListingCardView: View{
    let listing: Listing
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
            ZStack(alignment: .topTrailing){
                Image("hyundai")
                    .resizable()
                
                Button(action: {
                    print("하트 클릭")
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                }
            }
            
            Text(listing.model)
                .fontWeight(.semibold)
            HStack{
                Text("\(listing.mileage)Km")
                    .foregroundStyle(.gray)
                Image("iconlocation")
                    .resizable()
                    .frame(width: 13, height: 15)
                Text(listing.region)
                    .foregroundStyle(.gray)
            }
            Text("\(listing.price)만원")
                .padding(.top,4)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#3058EF"))
            
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(12)
        .frame(width: 170, height: 223)
        
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
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                Text(brand.name)
                    .foregroundColor(Color(hex: "#7F7F7F"))
            }
        }
    }
}
#Preview {
    HomeView()
    //ListingCardView()
    //BrandsIconView(brand: brandData[0])
}
